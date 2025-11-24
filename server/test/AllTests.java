package test;

import com.google.gson.Gson;
import com.mongodb.MongoException;
import com.mongodb.MongoSocketOpenException;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Sorts;
import org.bson.Document;
import org.bson.types.ObjectId;
import src.connection.IParceiro;
import src.protocol.Comunicado;
import src.processing.ProcessadorDeOperacao;
import src.domain.Turma;
import src.domain.LocPadrao;
import src.protocol.requests.GetTurmas;
import src.protocol.requests.CriarTurma;

import io.github.cdimascio.dotenv.Dotenv;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class AllTests {
    
    // MockParceiro para TestAbrirChamada
    static class MockParceiro implements IParceiro {
        public Comunicado last;
        @Override
        public void receba(Comunicado comunicado) throws Exception {
            this.last = comunicado;
            System.out.println("MockParceiro.receba -> " + comunicado.toString());
        }

        @Override
        public void adeus() throws Exception {
            // noop
        }
    }

    // ========== TestAbrirChamada ==========
    public static void testAbrirChamada() {
        System.out.println("\n=== TestAbrirChamada (interclasses) ===");
        // Load .env file (do NOT overwrite it)
        Dotenv dotenv = Dotenv.load();
        String mongoUri = dotenv.get("MONGO_URI");
        if (mongoUri == null || mongoUri.isEmpty()) {
            // Fallback to environment variable
            mongoUri = System.getenv("MONGO_URI");
        }
        if (mongoUri == null || mongoUri.isEmpty()) {
            // Final fallback to localhost
            mongoUri = "mongodb://localhost:27017";
        }
        System.out.println("Using MONGO_URI: " + mongoUri);

        Gson gson = new Gson();
        MockParceiro mock = new MockParceiro();

        try (MongoClient client = MongoClients.create(mongoUri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> users = db.getCollection("users");
            MongoCollection<Document> turmas = db.getCollection("turmas");
            MongoCollection<Document> aulas = db.getCollection("aulas");

            // Insert a test user
            Document student = new Document()
                    .append("uid", "test-abrir-" + UUID.randomUUID().toString())
                    .append("nome", "Aluno Abrir Test")
                    .append("email", "test-runner-abrir@local")
                    .append("tipo", "aluno")
                    .append("codigo", "code123")
                    .append("faceToken", "dummy-token")
                    .append("turmas", new ArrayList<ObjectId>());
            users.insertOne(student);
            ObjectId studentId = student.getObjectId("_id");
            System.out.println("Inserted student id: " + studentId.toHexString());

            // Create a turma containing the student
            Document localizacao = new Document().append("latitude", -23.0).append("longitude", -46.0);
            ArrayList<ObjectId> alunosIds = new ArrayList<>();
            alunosIds.add(studentId);
            Document turma = new Document()
                    .append("nome", "Turma Test Abrir")
                    .append("alunos", alunosIds)
                    .append("localizacaoPadrao", localizacao)
                    .append("aulas", new ArrayList<ObjectId>());
            turmas.insertOne(turma);
            ObjectId turmaId = turma.getObjectId("_id");
            System.out.println("Inserted turma id: " + turmaId.toHexString());

            // Build AbrirChamada JSON
            Document abrirDoc = new Document()
                    .append("operacao", "AbrirChamada")
                    .append("codigoTurma", turmaId.toHexString())
                    .append("latitude", -23.0)
                    .append("longitude", -46.0);

            String abrirJson = gson.toJson(abrirDoc);

            // Call the processor
            mock.last = null;
            boolean ret = ProcessadorDeOperacao.processar(abrirJson, mock, new ArrayList<>());
            System.out.println("Processar returned: " + ret);

            if (mock.last == null) {
                System.err.println("No response was received by MockParceiro from AbrirChamada");
            } else {
                System.out.println("Received response: " + mock.last.toString());
            }

            // Verify aula creation in DB
            Document aulaDoc = aulas.find(new Document("turmaId", turmaId))
                    .sort(Sorts.descending("dataAbertura")).first();

            if (aulaDoc == null) {
                System.err.println("TEST FAILED: aula document not found in DB for turmaId=" + turmaId.toHexString());
            } else {
                System.out.println("TEST OK: aula created with _id=" + aulaDoc.getObjectId("_id").toHexString());
                System.out.println("  codigo: " + aulaDoc.getString("codigo"));
                System.out.println("  presentes count: " + ((aulaDoc.get("presentes") instanceof java.util.List) ? ((java.util.List)aulaDoc.get("presentes")).size() : 0));
            }

            // Cleanup
            turmas.deleteOne(new Document("_id", turmaId));
            users.deleteOne(new Document("_id", studentId));
            aulas.deleteMany(new Document("turmaId", turmaId));

            System.out.println("Cleanup complete. Test finished.");
        } catch (MongoSocketOpenException mex) {
            System.err.println("Could not connect to MongoDB at " + mongoUri + " — connection refused.");
            System.err.println("Suggestions:");
            System.err.println("  1) Start a local MongoDB instance. On Windows, if installed as a service run: net start MongoDB");
            System.err.println("     Or run mongod manually (example):");
            System.err.println("       mkdir C:\\data\\db;\n       mongod --dbpath C:\\data\\db");
            System.err.println("  2) If you have MongoDB elsewhere, set the MONGO_URI environment variable to its connection string and re-run. Example (PowerShell):");
            System.err.println("       $env:MONGO_URI='mongodb://myhost:27017'; java -cp \"out;libs\\*\" test.AllTests");
            System.err.println("  3) Ask to convert this test to use an embedded MongoDB (flapdoodle) if you can't run a DB locally.");
            return;
        } catch (MongoException mex) {
            System.err.println("MongoDB error while running test: " + mex.getMessage());
            System.err.println("Check that MongoDB is reachable at: " + mongoUri);
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ========== GetTurmasTest ==========
    public static void testGetTurmasRetornarNullQuandoListaDeIdsForNula() {
        System.out.println("\n=== GetTurmasTest: deveRetornarNullQuandoListaDeIdsForNula ===");
        GetTurmas get = new GetTurmas("buscar", null);
        List<Turma> resultado = get.getTurmas();
        
        if (resultado == null) {
            System.out.println("TEST OK: Retornou null como esperado");
        } else {
            System.err.println("TEST FAILED: Deveria retornar null quando turmasId é nula");
        }
    }

    public static void testGetTurmasRetornarListaVaziaQuandoNaoHaTurmas() {
        System.out.println("\n=== GetTurmasTest: deveRetornarListaVaziaQuandoNaoHaTurmas ===");
        GetTurmas get = new GetTurmas("buscar", new ArrayList<>());
        List<Turma> resultado = get.getTurmas();
        
        if (resultado != null && resultado.isEmpty()) {
            System.out.println("TEST OK: Retornou lista vazia como esperado");
        } else {
            System.err.println("TEST FAILED: Deveria retornar lista vazia quando não há turmas cadastradas");
        }
    }

    public static void testGetTurmasRetornarListaVaziaQuandoIdsInexistentes() {
        System.out.println("\n=== GetTurmasTest: deveRetornarListaVaziaQuandoIdsInexistentes ===");
        List<String> idsInvalidos = List.of("000000000000000000000000");
        GetTurmas get = new GetTurmas("buscar", idsInvalidos);
        List<Turma> resultado = get.getTurmas();
        
        if (resultado != null && resultado.isEmpty()) {
            System.out.println("TEST OK: Retornou lista vazia para IDs inexistentes");
        } else {
            System.err.println("TEST FAILED: Deveria retornar lista vazia para IDs inexistentes");
        }
    }

    public static void testGetTurmasRetornarTrueQuandoObjetosIguais() {
        System.out.println("\n=== GetTurmasTest: deveRetornarTrueQuandoObjetosIguais ===");
        List<String> ids = List.of("507f1f77bcf86cd799439011");
        GetTurmas g1 = new GetTurmas("buscar", ids);
        GetTurmas g2 = new GetTurmas("buscar", ids);
        
        boolean saoIguais = g1.equals(g2);
        boolean mesmoHashCode = g1.hashCode() == g2.hashCode();
        
        if (saoIguais && mesmoHashCode) {
            System.out.println("TEST OK: Objetos iguais têm mesmo hashCode");
        } else {
            System.err.println("TEST FAILED: Objetos iguais devem ter o mesmo hashCode");
        }
    }

    // ========== CriarTurmaTest ==========
    public static void testCriarTurmaRetornarFalseQuandoAtributosForemNulos() {
        System.out.println("\n=== CriarTurmaTest: deveRetornarFalseQuandoAtributosForemNulos ===");
        CriarTurma criar = new CriarTurma();
        boolean resultado = criar.criarTurma();
        
        if (!resultado) {
            System.out.println("TEST OK: Retornou false quando atributos obrigatórios são nulos");
        } else {
            System.err.println("TEST FAILED: Deveria retornar false quando atributos obrigatórios são nulos");
        }
    }

    public static void testCriarTurmaLancarExcecaoQuandoNomeForNulo() {
        System.out.println("\n=== CriarTurmaTest: deveLancarExcecaoQuandoNomeForNulo ===");
        try {
            CriarTurma.gerarCodigo(null);
            System.err.println("TEST FAILED: Deveria lançar exceção quando o nome for nulo");
        } catch (IllegalArgumentException e) {
            System.out.println("TEST OK: Lançou exceção quando o nome for nulo");
        } catch (Exception e) {
            System.err.println("TEST FAILED: Lançou exceção diferente da esperada: " + e.getClass().getName());
        }
    }

    public static void testCriarTurmaLancarExcecaoQuandoNomeForVazio() {
        System.out.println("\n=== CriarTurmaTest: deveLancarExcecaoQuandoNomeForVazio ===");
        try {
            CriarTurma.gerarCodigo("   ");
            System.err.println("TEST FAILED: Deveria lançar exceção quando o nome for vazio");
        } catch (IllegalArgumentException e) {
            System.out.println("TEST OK: Lançou exceção quando o nome for vazio");
        } catch (Exception e) {
            System.err.println("TEST FAILED: Lançou exceção diferente da esperada: " + e.getClass().getName());
        }
    }

    public static void testCriarTurmaGerarCodigoNoFormatoCorreto() {
        System.out.println("\n=== CriarTurmaTest: deveGerarCodigoNoFormatoCorreto ===");
        String codigo = CriarTurma.gerarCodigo("Engenharia de Software");
        
        if (codigo != null && codigo.matches("^[A-Z]{1,4}-\\d{4}-[12]-[A-Z0-9]{5}$")) {
            System.out.println("TEST OK: Código gerado no formato correto: " + codigo);
        } else {
            System.err.println("TEST FAILED: O código deve seguir o padrão PREFIXO-ANO-SEMESTRE-IDUNICO. Recebido: " + codigo);
        }
    }

    public static void testCriarTurmaRetornarTrueQuandoTodosAtributosForemValidos() {
        System.out.println("\n=== CriarTurmaTest: deveRetornarTrueQuandoTodosAtributosForemValidos ===");
        try {
            CriarTurma criar = new CriarTurma();
            var nomeField = CriarTurma.class.getDeclaredField("nome");
            var descField = CriarTurma.class.getDeclaredField("descricao");
            var opField = CriarTurma.class.getDeclaredField("operacao");
            var objField = CriarTurma.class.getDeclaredField("objectId");
            var locField = CriarTurma.class.getDeclaredField("localizacaoPadrao");

            nomeField.setAccessible(true);
            descField.setAccessible(true);
            opField.setAccessible(true);
            objField.setAccessible(true);
            locField.setAccessible(true);

            nomeField.set(criar, "Turma Teste");
            descField.set(criar, "Descrição da turma");
            opField.set(criar, "criar");
            objField.set(criar, "507f1f77bcf86cd799439011"); // ObjectId válido fictício
            locField.set(criar, new LocPadrao(10.5, 20.7));

            boolean resultado = criar.criarTurma();
            
            if (resultado) {
                System.out.println("TEST OK: Retornou true quando todos os atributos são válidos");
            } else {
                System.err.println("TEST FAILED: Deveria retornar true quando todos os atributos são válidos");
            }
        } catch (Exception e) {
            System.err.println("TEST FAILED: Erro ao executar teste: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ========== Main ==========
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("    EXECUTANDO TODOS OS TESTES");
        System.out.println("========================================");

        // TestAbrirChamada
        testAbrirChamada();

        // GetTurmasTest
        testGetTurmasRetornarNullQuandoListaDeIdsForNula();
        testGetTurmasRetornarListaVaziaQuandoNaoHaTurmas();
        testGetTurmasRetornarListaVaziaQuandoIdsInexistentes();
        testGetTurmasRetornarTrueQuandoObjetosIguais();

        // CriarTurmaTest
        testCriarTurmaRetornarFalseQuandoAtributosForemNulos();
        testCriarTurmaLancarExcecaoQuandoNomeForNulo();
        testCriarTurmaLancarExcecaoQuandoNomeForVazio();
        testCriarTurmaGerarCodigoNoFormatoCorreto();
        testCriarTurmaRetornarTrueQuandoTodosAtributosForemValidos();

        System.out.println("\n========================================");
        System.out.println("    TODOS OS TESTES CONCLUÍDOS");
        System.out.println("========================================");
    }
}

