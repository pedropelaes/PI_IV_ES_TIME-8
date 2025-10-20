---

![Logo Vocatio](vocatio_res/logo_vocatio_transparente.png)

---

## 📖 Sobre o Projeto  
O **Vocattio** é um aplicativo multiplataforma criado para otimizar o **registro de presença em salas de aula universitárias**.  

Ele substitui a chamada oral tradicional — que consome em média **13% do tempo da aula** e é suscetível a falhas — por um processo **rápido, automatizado e confiável**, baseado em QR Code, geolocalização e autenticação biométrica.  

---

## 🛠️ Tecnologias  
- **Frontend/Backend:** Flutter (Dart)  
- **Servidor:** Java  
- **Banco de Dados:** MongoDB  
- **Testes:** JUnit  

O servidor em Java terá o papel de **intermediário entre o aplicativo e o banco de dados**.

Quando o app precisar realizar uma operação (como registrar presença, criar turmas ou consultar relatórios), ele fará uma **requisição ao servidor**.
A biblioteca MongoDB Java Driver será utilizada.

---

## ✨ Funcionalidades  

👩‍🏫 **Para Professores**  
- Criar turmas e adicionar alunos  
- Iniciar chamadas com QR Code dinâmico ou código temporário  
- Visualizar relatórios de presença  

🎓 **Para Alunos**  
- Entrar em turmas com código fornecido  
- Validar identidade por biometria  
- Registrar presença por QR Code ou código  
- Consultar histórico pessoal de presenças  

⚙️ **Funcionalidades Gerais**  
- Validação de presença por geolocalização  
- Limite de tempo para registro  
- Armazenamento automático em banco de dados  
- Suporte a modo offline  

---

## 📂 Estrutura do Repositório  
📦 vocatio

┣ 📂 frontend # Aplicativo Flutter

┣ 📂 backend # API em Java

┣ 📂 docs # Relatórios, protótipos e diagramas

┣ LICENSE

┗ README.md

---

## 📌 Status do Projeto

📍 Em desenvolvimento – MVP em andamento com foco nas funcionalidades principais.

---
