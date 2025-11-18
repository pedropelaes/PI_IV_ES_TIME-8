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
- Criar e gerenciar turmas;  
- Iniciar chamadas com QR Code dinâmico e código temporário;
- Visualizar relatórios de presença;
- Editar presenças.

🎓 **Para Alunos**  
- Entrar em turmas com código fornecido;  
- Validar identidade por biometria facial; 
- Registrar presença por QR Code ou código;  
- Consultar histórico pessoal de presenças.  

⚙️ **Funcionalidades Gerais**  
- Validação de presença por geolocalização, biometria e código temporário;  
- Limite de tempo para registro;  
- Armazenamento automático em banco de dados;  

---

## 📂 Estrutura do Repositório  
📦 vocatio

┣ 📂 app # Aplicativo Flutter

┣ 📂 server # API em Java

┣ 📂 vocattio_res # Relatórios, protótipos e diagramas

┣ LICENSE

┗ README.md

---

## 📄 O Problema
A chamada oral tradicional consome tempo valioso de aula e é suscetível a falhas humanas. A imprecisão no registro gera frustração para professores e pode prejudicar a frequência real dos alunos.

## 🎯 Objetivos
Otimização de Tempo: Reduzir drasticamente o tempo gasto com chamadas.
Confiabilidade: Automatizar o processo para eliminar erros de escuta ou confusão.
Justiça: Garantir um registro de frequência preciso e auditável.
