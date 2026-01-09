# 📦 WickCorreio

> **Logística Interna Inteligente.** Um sistema Mobile e Backend para rastreamento, gestão e entrega de encomendas corporativas em tempo real.

![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Backend-Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)


---

## 🚚 O Desafio Logístico

Em grandes empresas, o fluxo de recebimento de encomendas na portaria e a entrega ao destinatário final (desk delivery) pode ser caótico.
* **Problemas:** Encomendas perdidas, falta de rastreabilidade interna e dependência de livros de protocolo manuais.
* **O Impacto:** Facilities sobrecarregado e colaboradores insatisfeitos com a demora na notificação.

---

## 💡 A Solução Técnica

O **WickCorreio** é uma solução Full Stack composta por dois módulos principais:
1.  **App Mobile (Flutter):** Focado na operação (Recebimento e Baixa). Roda em coletores de dados Android ou smartphones comuns.
2.  **Backend (Python API):** Orquestrador que gerencia o banco de dados MySQL e as notificações.

O sistema elimina o papel: o operador escaneia o pacote, e a API automaticamente identifica o dono e dispara a notificação.

---

## 🔄 Fluxo de Dados (Workflow)

Sem a necessidade de telas complexas, o fluxo lógico da aplicação é direto e eficiente:

1.  📦 **Chegada:** Operador usa o App para ler o código de barras da transportadora.
2.  📡 **API Check:** O App consulta o Backend para vincular aquele código a um funcionário.
3.  🔔 **Notificação:** O Backend processa a entrada e envia um e-mail/alerta para o colaborador.
4.  ✍️ **Entrega:** Na retirada, o colaborador assina digitalmente no dispositivo do operador.

---

## 🛠️ Arquitetura do Sistema

O projeto adota uma arquitetura cliente-servidor clássica via API REST conectada a um banco relacional robusto.

```mermaid
graph TD
    subgraph "Front-End Mobile"
        Scanner[📸 Leitor de Barcode]
        UI[📱 Interface Flutter]
    end

    subgraph "Back-End Python"
        API[🐍 API Flask/FastAPI]
        Auth[🔐 Validação de Token]
        Notify[📧 Serviço de Email]
    end

    subgraph "Data"
        DB[(🗄️ Banco de Dados MySQL)]
    end

    Scanner --> UI
    UI -- "POST /api/encomenda" --> API
    API --> Auth
    API -- "Query SQL / ORM" --> DB
    API -- "Trigger" --> Notify
