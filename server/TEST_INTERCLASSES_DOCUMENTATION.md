# Testes Interclasses - Funcionalidade de Abrir Chamada (AbrirChamada)

## Visão Geral

Este documento descreve os testes interclasses desenvolvidos para validar a funcionalidade principal do servidor: **professor abre chamada** e **aluno registra presença**. Os testes automatizados exercitam a sequência de métodos entre classes, desde a recepção da chamada JSON até a inserção de dados no MongoDB e retorno da resposta.

---

## Cenário NORMAL (Funcionamento Padrão)

### Objetivo
Professor abre uma chamada com sucesso; a aula é criada no MongoDB com lista de presença inicializada.

### Sequência de Classes e Métodos

```
1. Cliente (Aplicação)
   └─> Envia JSON: {"operacao":"AbrirChamada", "codigoTurma":"...", "latitude":-23.0, "longitude":-46.0}

2. ProcessadorDeOperacao.processar(json, remetente, usuarios)
   ├─> Faz parsing do JSON com Gson
   ├─> Detecta "operacao":"AbrirChamada"
   └─> Instancia: new AbrirChamada() via Gson.fromJson(json, AbrirChamada.class)

3. AbrirChamada.abrir()
   ├─> Carrega MONGO_URI do .env via Dotenv.load()
   ├─> Conecta ao MongoDB: MongoClients.create(uri)
   ├─> Busca turma: turmas.find(Filters.eq("_id", new ObjectId(codigoTurma))).first()
   │   └─> Validação: se turma == null, retorna null e ProcessadorDeOperacao envia falha
   ├─> Se lat/lon == 0, faz fallback com localizacaoPadrao da turma
   ├─> Busca lista de alunos da turma: ArrayList<ObjectId> alunosIds = turma.get("alunos")
   ├─> Para cada alunoId:
   │   └─> Busca nome do aluno: users.find(Filters.eq("_id", alunoId)).first()
   │   └─> Cria snapshot de presença: {"alunoId":..., "nome":"...", "presente":false}
   ├─> Gera código único: "CHAMADA-" + UUID.substring(0,6)
   ├─> Gera chave TOTP: SecretGenerator.generate(64)
   ├─> Cria documento aula:
   │   {
   │     "turmaId": ObjectId(codigoTurma),
   │     "codigo": "CHAMADA-ABC123",
   │     "chaveTOTP": "...",
   │     "aberta": true,
   │     "latitude": -23.0,
   │     "longitude": -46.0,
   │     "dataAbertura": new Date(),
   │     "presentes": [ {alunoId, nome, presente:false}, ... ]
   │   }
   ├─> Insere documento aula: aulas.insertOne(aula)
   ├─> Atualiza turma:
   │   ├─> push("aulas", aulaId)
   │   └─> set("atualizadoEm", new Date())
   └─> Retorna codigoChamada: "CHAMADA-ABC123"

4. ProcessadorDeOperacao.processar() (continuação)
   ├─> Recebe codigoChamada (não null)
   ├─> Cria ResultadoAbrirChamada(true, "ResultadoAbrirChamada", codigoChamada)
   └─> Envia resposta: remetente.receba(resultado)

5. IParceiro.receba(Comunicado resultado)
   └─> Aplicação recebe: {"resultado":true, "operacao":"ResultadoAbrirChamada", "codigoChamada":"CHAMADA-ABC123"}
```

### Validações Esperadas (NORMAL)
- ✅ `ProcessadorDeOperacao.processar()` retorna `false` (indica que a operação foi processada e não precisa continuar)
- ✅ `ResultadoAbrirChamada.resultado == true`
- ✅ Documento `aula` inserido no MongoDB com:
  - Campo `codigo` preenchido
  - Campo `presentes` é um array com 1+ documentos (alunos da turma)
  - Campo `aberta == true`
  - Campos `latitude` e `longitude` preenchidos

---

## Variação 1 - Turma Inválida / Não Encontrada

### Objetivo
Testar comportamento quando `codigoTurma` refere a uma turma inexistente ou inválido (ObjectId inválido).

### Sequência de Classes e Métodos

```
1. Cliente
   └─> Envia JSON com codigoTurma = ObjectId aleatório/inexistente

2. ProcessadorDeOperacao.processar(json, ...)
   └─> Instancia AbrirChamada

3. AbrirChamada.abrir()
   ├─> Busca turma: turmas.find(Filters.eq("_id", new ObjectId(codigoTurma))).first()
   ├─> Turma não encontrada: turma == null
   ├─> Loga: "Turma não encontrada!"
   └─> Retorna null

4. ProcessadorDeOperacao.processar() (continuação)
   ├─> codigoChamada == null
   ├─> Verifica: boolean codigoChamadaNotNull = codigoChamada != null → false
   ├─> Cria ResultadoAbrirChamada(false, "ResultadoAbrirChamada", null)
   └─> Envia: remetente.receba(resultado)

5. IParceiro.receba(...)
   └─> Aplicação recebe: {"resultado":false, "operacao":"ResultadoAbrirChamada", "codigoChamada":null}
```

### Validações Esperadas (Variação 1)
- ✅ `ResultadoAbrirChamada.resultado == false`
- ✅ `ResultadoAbrirChamada.codigoChamada == null`
- ✅ **Nenhum** documento `aula` é inserido no MongoDB
- ✅ Turma **não é atualizada**

---

## Variação 2 - Coordenadas Zeradas (Fallback para Localização Padrão)

### Objetivo
Testar que quando lat/lon chegam como 0, o sistema faz fallback com a `localizacaoPadrao` da turma.

### Sequência de Classes e Métodos

```
1. Cliente
   └─> Envia JSON com latitude=0, longitude=0

2. ProcessadorDeOperacao.processar(json, ...)
   └─> Instancia AbrirChamada

3. AbrirChamada.abrir()
   ├─> Busca turma (válida, encontrada)
   ├─> Verifica: if(this.latitude == 0 && this.longitude == 0)
   ├─> Busca localizacaoPadrao: Document cordturma = turma.get("localizacaoPadrao")
   ├─> Se cordturma != null:
   │   ├─> setLatitude(cordturma.getDouble("latitude"))
   │   └─> setLongitude(cordturma.getDouble("longitude"))
   ├─> Continua com latitude/longitude da turma
   ├─> Cria aula com as coordenadas do fallback
   ├─> Insere aula e atualiza turma
   └─> Retorna codigoChamada

4. ProcessadorDeOperacao.processar() (continuação)
   ├─> codigoChamada != null
   ├─> Cria ResultadoAbrirChamada(true, ...)
   └─> Envia resposta

5. IParceiro.receba(...)
   └─> Aplicação recebe sucesso
```

### Validações Esperadas (Variação 2)
- ✅ `ResultadoAbrirChamada.resultado == true`
- ✅ Documento `aula` criado com:
  - `latitude` == `localizacaoPadrao.latitude` da turma
  - `longitude` == `localizacaoPadrao.longitude` da turma

---

## Arquivo de Teste: `server/test/TestAbrirChamada.java`

### O que o teste faz

1. **Setup**
   - Carrega `.env` (sem sobrescrevê-lo) via `Dotenv.load()`
   - Extrai `MONGO_URI` (prioridade: `.env` > variável de ambiente > fallback localhost)
   - Conecta ao MongoDB

2. **Preparação de dados (Cenário NORMAL)**
   - Insere um usuário de teste (`student`) com nome "Aluno Abrir Test"
   - Insere uma turma de teste (`turma`) contendo o aluno, com `localizacaoPadrao`

3. **Executar teste**
   - Constrói JSON de `AbrirChamada` com:
     - `codigoTurma`: ID da turma de teste
     - `latitude`: -23.0
     - `longitude`: -46.0
   - Chama `ProcessadorDeOperacao.processar(json, mockParceiro, usuariosVazio)`
   - Captura a resposta via `MockParceiro.receba(...)`

4. **Validações**
   - Verifica se `MockParceiro` recebeu uma resposta (não null)
   - Busca o documento `aula` criado no MongoDB
   - Valida:
     - Documento existe
     - Campo `codigo` preenchido
     - Array `presentes` contém 1 aluno
   - Imprime resultado: `TEST OK` ou `TEST FAILED`

5. **Cleanup**
   - Remove turma, usuário e aulas criadas para não poluir o banco

### Como executar o teste

**Pré-requisitos:**
- Java 11+ instalado
- MongoDB Atlas (ou local) acessível
- `.env` no diretório `server` com `MONGO_URI`

**Comandos (PowerShell, diretório `server`):**

```powershell
# 1. Preparar variáveis de classpath
$cp = (Get-ChildItem -Path .\libs -Filter *.jar | ForEach-Object { $_.FullName }) -join ';'

# 2. Compilar src + test
$srcFiles = Get-ChildItem -Path .\src -Recurse -Filter *.java | ForEach-Object { $_.FullName }
$testFiles = Get-ChildItem -Path .\test -Recurse -Filter *.java | ForEach-Object { $_.FullName }
if (!(Test-Path -Path .\out)) { New-Item -ItemType Directory -Path .\out | Out-Null }
javac -cp "$cp" -d out $srcFiles $testFiles

# 3. Executar o teste
java -cp "out;$cp" test.TestAbrirChamada
```

**Saída esperada (sucesso):**
```
=== TestAbrirChamada (interclasses) ===
Using MONGO_URI: mongodb+srv://...
Inserted student id: 691661296971811714ab47ff
Inserted turma id: 6916612b6971811714ab4800
Operação recebida: 'AbrirChamada'
Chamada aberta com sucesso! Código: CHAMADA-B0EDEF
MockParceiro.receba -> { Operacao: ResultadoAbrirChamada Resultado: true }
Processar returned: false
Received response: { Operacao: ResultadoAbrirChamada Resultado: true }
TEST OK: aula created with _id=6916612b6971811714ab4802
  codigo: CHAMADA-B0EDEF
  presentes count: 1
Cleanup complete. Test finished.
```

---

## Resumo Técnico - Fluxo Interclasses

### Classes Participantes

| Classe | Método | Responsabilidade |
|--------|--------|------------------|
| `ProcessadorDeOperacao` | `processar(json, remetente, usuarios)` | Recebe JSON, identifica operação, instancia request, captura resposta |
| `AbrirChamada` | `abrir()` | Valida turma, busca alunos, gera código/TOTP, cria aula, atualiza turma |
| `MongoDatabase` / `MongoCollection` | `find()`, `insertOne()`, `updateOne()` | Persistência de dados |
| `ResultadoAbrirChamada` | construtor | Encapsula resultado (bool, operação, código) |
| `IParceiro` / `MockParceiro` | `receba(Comunicado)` | Envia/recebe mensagens (comunicação) |
| `Dotenv` | `load()`, `get()` | Carrega variáveis de ambiente (config) |
| `Gson` | `fromJson()`, `toJson()` | Serialização/desserialização JSON |

### Pontos Críticos de Falha

1. **MongoDB Indisponível** → `MongoSocketOpenException` → Teste termina com erro de conexão
2. **Turma não encontrada** → `turma == null` → Retorna `null` → Resposta de falha
3. **alunosIds vazio** → `listaPresenca` vazia → Aula criada mas sem alunos
4. **ObjectId inválido** → `IllegalArgumentException` em `new ObjectId(codigoTurma)` → Exceção

### Transações / Atomicidade

- ⚠️ **Não há transação atômica**: Se a inserção da `aula` funciona mas a atualização da `turma` falha, a `aula` fica órfã.
- ⚠️ **Recomendação**: Usar MongoDB Transactions (replica set required) ou validar após leitura.

---

## Próximos Passos

### Testes Adicionais Recomendados

1. **Teste para `RegistrarPresenca`**
   - Cenário NORMAL: aluno registra presença (dentro do raio, face válida, código TOTP válido)
   - Variação 1: aluno fora do raio permitido
   - Variação 2: aluno já registrado (duplicado)

2. **Teste para falhas de validação**
   - `AbrirChamada` com ObjectId inválido (string não é um ObjectId válido)
   - `AbrirChamada` com codigoTurma vazio/null

3. **Teste integrado (end-to-end)**
   - Abrir chamada → Múltiplos alunos registram presença → Validar lista de presença final

4. **Teste de performance**
   - Abrir chamada com turma de 100+ alunos
   - Registrar presença de 10+ alunos em paralelo

---

## Notas Importantes

- **Variáveis de Ambiente**: O teste lê `.env` via `Dotenv.load()` e **não o sobrescreve**.
- **Limpeza de Dados**: O teste remove documentos criados ao final para não poluir o banco.
- **Logs Verbosos**: MongoDB driver log é normal (INFO nível); erros aparecem em `[main] ERROR`.
- **MockParceiro**: Implementação simples de `IParceiro` que apenas captura a resposta; em produção, seria uma conexão WebSocket real.

---

## Referências

- Arquivo de teste: `server/test/TestAbrirChamada.java`
- Classes testadas: `server/src/processing/ProcessadorDeOperacao.java`, `server/src/protocol/requests/AbrirChamada.java`
- Respostas: `server/src/protocol/responses/ResultadoAbrirChamada.java`, `ResultadoOperacao.java`
