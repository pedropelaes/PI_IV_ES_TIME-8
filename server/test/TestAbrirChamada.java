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

import io.github.cdimascio.dotenv.Dotenv;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.UUID;

public class TestAbrirChamada {
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

    public static void main(String[] args) {
        System.out.println("=== TestAbrirChamada (interclasses) ===");
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
            System.err.println("       $env:MONGO_URI='mongodb://myhost:27017'; java -cp \"out;libs\\*\" test.TestAbrirChamada");
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
}
