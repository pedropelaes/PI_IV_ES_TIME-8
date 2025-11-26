>Este projeto foi desenvolvido para a matéria de Projeto Integrador IV, do 4° semestre do curso de Engenharia de Software da PUC-Campinas.

>Grupo:
>[Daniel Henrique Inoue Jange](https://github.com/djange2);
>[Lucas Anelli Bissi](https://github.com/Luked20);
>[Igor Ribeiro Cunha](https://github.com/igorrc14);
>[Pedro Facine Nery](https://github.com/pedrofacine);
>[Pedro Pelaes Malinconico](https://github.com/pedropelaes);
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

APIs utilizadas:
- Face++ - Para validar a chamada via reconhecimento facial;
- Firebase API - Para autenticação no aplicativo;
- Google Maps SDK - Para seleção de localização padrão para uma turma;
- Geolocator - Para coleta de localização dos usuários a fim de validação;

[Protótipo do projeto](https://www.figma.com/design/Sh4IZqG0kfoT9GTxNxywfw/PI4?node-id=67-2&t=0XijwI3A1Gjl2XIN-1)

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
📦 vocattio

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

---

## ▶ Como executar o Vocattio:

Para rodar o projeto localmente, siga os passos abaixo para configurar o servidor e o aplicativo.

### 📋 Pré-requisitos Gerais
Antes de começar, certifique-se de ter:
- **Java JDK** (versão 11 ou superior) instalado.
- **Flutter SDK** instalado e configurado.
- **MongoDB**: Uma instância rodando (local ou Atlas/Cloud).
- **Conta [Face++](https://www.faceplusplus.com/)** (para obter as API Keys e criar um FaceSet).
- **Conta Firebase**: Para autenticação.

---

### 🖥️ 1. Servidor (Backend Java)

1. Navegue até a pasta `server`.
2. Crie um arquivo chamado `.env` na raiz da pasta `server` e preencha com suas credenciais:

```env
MONGO_URI=sua_string_de_conexao_mongodb
FACESET_TOKEN=token_do_seu_faceset_faceplusplus
FACE_API_KEY=sua_api_key_faceplusplus
FACE_API_SECRET=sua_api_secret_faceplusplus
```
3. Execute o servidor:
   - **Windows**: Execute o arquivo `run.bat`;
   - **Linux/Mac**: Execute o arquivo `run.sh`(certifique-se de dar permissão de execução com `chmod +x run.sh`).

   **Nota:** O servidor iniciará por padrão na porta 300(TCP Socket) e 3001(WebSocket).


### 📱 2 - Aplicativo (Flutter Mobile & Web):
**Pré-requisitos de ambiente:**
- **[Flutter SDK](https://docs.flutter.dev/get-started)**;
- **Android:** Android Studio instalado;
- **IOS:** Xcode instalado(apenas macOS);
- **Web:** Navegador Chrome/Edge/Ou outro compativel com flutter.

**Configuração:**
1. Navegue até a pasta `app/vocatio`.
2. Crie um arquivo chamado `.env` na raiz da pasta `vocatio` e preencha com suas credenciais:

```env
FIREBASE_API_WEB_KEY=sua_api_key_firebase
GOOGLE_MAPS_API_KEY=sua_api_key_google_maps
```
3. Navegue até a pasta `app/vocatio/lib/services/socket/` e abra o arquivo `socket_service.dart`.
4. Na constante host, coloque o IP do seu computador, ou digite localhost, para testar localmente.
```socket_service.dart
const String host = 'SEU IP'
```

5. Para executar, no terminal, dentro de `app/vocatio`, execute:
```
# Para rodar diretamente
flutter run
# Para buildar
flutter build (sua plataforma)
```
