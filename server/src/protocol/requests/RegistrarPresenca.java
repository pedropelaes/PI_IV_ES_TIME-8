package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;

public class RegistrarPresenca {
    private String aulaId;
    private String alunoId;

    public RegistrarPresenca(String json) {
        // Converte o JSON recebido em um Document
        Document doc = Document.parse(json);
        this.aulaId = doc.getString("aulaId");
        this.alunoId = doc.getString("alunoId");
    }

    public boolean registrarPresenca() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient mongoClient = MongoClients.create(uri)) {
            MongoDatabase database = mongoClient.getDatabase("vocattio");
            MongoCollection<Document> aulas = database.getCollection("aulas");

            // Adiciona o ID do aluno no array "presentes" (sem duplicar)
            aulas.updateOne(
                    Filters.eq("_id", new ObjectId(aulaId)),
                    Updates.addToSet("presentes", new ObjectId(alunoId))
            );

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
