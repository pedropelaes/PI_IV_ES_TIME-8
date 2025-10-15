import io.github.cdimascio.dotenv.Dotenv;
import com.mongodb.client.*;
import org.bson.Document;

public class TesteMongo {
    private String nome;
    private String email;
    private int idade;

    public TesteMongo() {
    }

    public boolean criarDocumento() {
        Dotenv dotenv = Dotenv.load();

        // Lê a variável
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> colecao = db.getCollection("users");

            Document usuario = new Document("nome", this.nome)
                    .append("idade", this.idade)
                    .append("email", this.email);

            colecao.insertOne(usuario);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}


