from flask import Flask, request, jsonify
from flask_bcrypt import Bcrypt
import pymysql
import hashlib
from datetime import datetime
import pytz

#Conexão com o banco de dados
from connection import connect_db

# --- Inicialização da Aplicação ---
app = Flask(__name__)
bcrypt = Bcrypt(app)

# --- Endpoint de Registro de Usuário ---
@app.route('/register', methods=['POST'])
def register():
    # Pega os dados enviados pelo app (em formato JSON)
    data = request.get_json()
    re = data.get('re')
    password = data.get('password')
    location = data.get('location')

    # Validação simples para garantir que os campos necessários foram enviados
    if not re or not password or not location:
        return jsonify({"error": "Dados incompletos. RE, senha e localização são obrigatórios."}), 400

    # Gera o hash seguro da senha
    password_hash = bcrypt.generate_password_hash(password).decode('utf-8')

    conn = None
    try:
        conn = connect_db()
        with conn.cursor() as cursor:
            # Query SQL para inserir um novo usuário na tabela
            sql = "INSERT INTO users (re, password_hash, location) VALUES (%s, %s, %s)"
            
            # Executa a query de forma segura para evitar SQL Injection
            cursor.execute(sql, (re, password_hash, location))
        
        conn.commit() # Confirma a inserção no banco
        
        return jsonify({"message": f"Usuário com RE {re} criado com sucesso!"}), 201

    except pymysql.err.IntegrityError as e:
        # Este erro acontece se tentarmos inserir um 're' que já existe (por causa do UNIQUE)
        return jsonify({"error": "Usuário com este RE já existe."}), 409
    
    except Exception as e:
        return jsonify({"error": f"Ocorreu um erro no servidor: {e}"}), 500

    finally:
        if conn:
            conn.close()

# --- Endpoint de Login de Usuário ---
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    re = data.get('re')
    password = data.get('password')

    if not re or not password:
        return jsonify({"error": "RE e senha são obrigatórios."}), 400

    conn = None
    try:
        conn = connect_db()
        with conn.cursor() as cursor:
            # Busca o usuário pelo RE
            sql = "SELECT * FROM users WHERE re = %s"
            cursor.execute(sql, (re,))
            user = cursor.fetchone() # Pega o primeiro resultado (deve ser único)

            # Verifica se o usuário existe E se a senha fornecida corresponde ao hash no banco
            if user and bcrypt.check_password_hash(user['password_hash'], password):
                # Login bem-sucedido!
                return jsonify({
                    "message": "Login bem-sucedido!",
                    "user": {
                        "re": user['re'],
                        "location": user['location']
                    }
                }), 200
            else:
                # Se o usuário não existe ou a senha está incorreta
                return jsonify({"error": "Credenciais inválidas."}), 401
    
    except Exception as e:
        return jsonify({"error": f"Ocorreu um erro no servidor: {e}"}), 500

    finally:
        if conn:
            conn.close()

# --- Rota de Adicionar malote ---
@app.route('/malotes', methods=['POST'])
def criar_malote():
    data = request.get_json()
    # Adicionamos 'created_by_re' para saber quem criou
    nome = data.get('nome')
    origem = data.get('origem')
    destinatario = data.get('destinatario')
    destino = data.get('destino')
    created_by_re = data.get('created_by_re')

    if not all([nome, origem, destinatario, destino, created_by_re]):
        return jsonify({"error": "Todos os campos são obrigatórios."}), 400

    conn = None
    try:
        conn = connect_db()
        with conn.cursor() as cursor:
            # 1. Insere o malote sem o hash para gerar o ID
            sql_insert = """
            INSERT INTO malotes (nome, origem, destinatario, destino, created_by_re)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql_insert, (nome, origem, destinatario, destino, created_by_re))
            malote_id = cursor.lastrowid # Pega o ID que acabou de ser criado

            # 2. Gera um hash único para o QR Code
            timestamp = datetime.now().isoformat()
            unique_string = f"{malote_id}-{timestamp}-{nome}"
            qr_hash = hashlib.sha256(unique_string.encode()).hexdigest()
            barcode = f"WK{malote_id:06d}" #Formata o ID

            # 3. Atualiza o registro do malote com o hash gerado
            sql_update = "UPDATE malotes SET qr_hash = %s, barcode = %s WHERE id = %s"
            cursor.execute(sql_update, (qr_hash, barcode, malote_id))
        
        conn.commit()

        # Retorna os dados do malote criado para o app
        return jsonify({
            "message": "Malote criado com sucesso!",
            "malote": {
                "id": malote_id,
                "nome": nome,
                "origem": origem,
                "destinatario": destinatario,
                "destino": destino,
                "qr_hash": qr_hash,
                "barcode": barcode 
            }
        }), 201

    except Exception as e:
        if conn:
            conn.rollback() # Desfaz a operação em caso de erro
        return jsonify({"error": f"Ocorreu um erro no servidor: {e}"}), 500

    finally:
        if conn:
            conn.close()

# --- Rota de Localidades ---
@app.route('/localidades', methods=['GET'])
def get_localidades():
    conn = None
    try:
        conn = connect_db()
        with conn.cursor() as cursor:
            cursor.execute("SELECT nome FROM localidades ORDER BY nome ASC")
            # O cursor retorna tuplas, então precisamos extrair o primeiro elemento de cada
            localidades = [item['nome'] for item in cursor.fetchall()]
            return jsonify(localidades)
    except Exception as e:
        return jsonify({"error": f"Ocorreu um erro no servidor: {e}"}), 500
    finally:
        if conn:
            conn.close()

# --- Rota de atualizar ---
@app.route('/malotes/atualizar', methods=['POST'])
def atualizar_malote():
    data = request.get_json()
    # O app vai enviar um 'codigo', que pode ser um ou outro
    codigo = data.get('codigo') 
    usuario_re = data.get('usuario_re')
    localizacao_atual = data.get('localizacao_atual')

    if not all([codigo, usuario_re, localizacao_atual]):
        return jsonify({"error": "Código do malote, RE e localização são obrigatórios."}), 400

    conn = None
    try:
        conn = connect_db()
        with conn.cursor() as cursor:
            # Procura o malote onde o qr_hash OU o barcode correspondem ao código enviado
            sql_find = "SELECT id, status, origem, destino FROM malotes WHERE qr_hash = %s OR barcode = %s"
            cursor.execute(sql_find, (codigo, codigo))
            malote = cursor.fetchone()

            if not malote:
                return jsonify({"error": "Malote não encontrado."}), 404

            malote_id = malote['id']
            status_atual = malote['status']
            origem = malote['origem']
            destino = malote['destino']
            novo_status = ''

            # 2. Lógica para determinar o próximo status
            is_origem_cd = origem in ['CDA', 'CDB']
            is_destino_cd = destino in ['CDA', 'CDB']

            if status_atual == 'Criado na Origem':
                if is_origem_cd or is_destino_cd:
                    novo_status = 'Em trânsito para o destino final'
                else:
                    novo_status = 'Em trânsito para Centro de Distribuição'
            elif status_atual == 'Em trânsito para Centro de Distribuição':
                novo_status = 'Recebido no Centro de Distribuição'
            elif status_atual == 'Recebido no Centro de Distribuição':
                novo_status = 'Em trânsito para o destino final'
            elif status_atual == 'Em trânsito para o destino final':
                novo_status = 'Entregue'
            elif status_atual == 'Entregue':
                return jsonify({"message": "Este malote já foi entregue."}), 200
            else:
                return jsonify({"error": "Status desconhecido do malote."}), 400

            # 3. Pega a data e hora no fuso horário de São Paulo
            tz_sp = pytz.timezone('America/Sao_Paulo')
            timestamp_sp = datetime.now(tz_sp)

            # 4. Insere o novo evento no histórico
            sql_historico = """
            INSERT INTO malote_historico (malote_id, status, localizacao, usuario_re, timestamp)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql_historico, (malote_id, novo_status, localizacao_atual, usuario_re, timestamp_sp))

            # 5. Atualiza o status principal do malote
            cursor.execute("UPDATE malotes SET status = %s WHERE id = %s", (novo_status, malote_id))
            
            conn.commit()

            return jsonify({
                "message": "Status do malote atualizado com sucesso!",
                "novo_status": novo_status,
                "localizacao": localizacao_atual,
                "malote_id": malote_id
            }), 200

    except Exception as e:
        if conn: conn.rollback()
        return jsonify({"error": f"Ocorreu um erro no servidor: {e}"}), 500
    finally:
        if conn: conn.close()

@app.route('/malotes', methods=['GET'])
def get_malotes():
    # Pega os parâmetros da URL, como ?status_ne=Entregue
    args = request.args
    query = "SELECT id, nome, barcode, status, destino FROM malotes"
    params = []

    # Filtro para buscar por status DIFERENTE de um valor
    if 'status_ne' in args: # ne = Not Equal
        query += " WHERE status != %s"
        params.append(args['status_ne'])
    
    # Filtro para pesquisar por um termo (no nome ou barcode)
    if 'search' in args:
        search_term = f"%{args['search']}%"
        # Adiciona WHERE ou AND dependendo se já existe um filtro
        if 'WHERE' in query:
            query += " AND (nome LIKE %s OR barcode LIKE %s)"
        else:
            query += " WHERE nome LIKE %s OR barcode LIKE %s"
        params.extend([search_term, search_term])
        
    query += " ORDER BY id DESC" # Mostra os mais recentes primeiro

    conn = None
    try:
        conn = connect_db()
        with conn.cursor() as cursor:
            cursor.execute(query, params)
            malotes = cursor.fetchall()
            return jsonify(malotes)
    except Exception as e:
        return jsonify({"error": f"Ocorreu um erro no servidor: {e}"}), 500
    finally:
        if conn: conn.close()


# ROTA 2: Para pegar o histórico de um malote específico
@app.route('/malotes/<string:barcode>/historico', methods=['GET'])
def get_malote_historico(barcode):
    query = """
    SELECT h.status, h.localizacao, h.timestamp
    FROM malote_historico h
    JOIN malotes m ON h.malote_id = m.id
    WHERE m.barcode = %s
    ORDER BY h.timestamp ASC
    """
    conn = None
    try:
        conn = connect_db()
        with conn.cursor() as cursor:
            cursor.execute(query, (barcode,))
            historico = cursor.fetchall()

            # Formata a data e hora para o padrão brasileiro antes de enviar
            for evento in historico:
                if evento['timestamp']:
                    evento['timestamp'] = evento['timestamp'].strftime('%d/%m/%Y %H:%M:%S')

            return jsonify(historico)
    except Exception as e:
        return jsonify({"error": f"Ocorreu um erro no servidor: {e}"}), 500
    finally:
        if conn: conn.close()

# --- Bloco de Execução Principal ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=0000, debug=True)