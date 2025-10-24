package src.protocol.requests;

import io.github.cdimascio.dotenv.Dotenv;
import com.mongodb.client.*;
import org.bson.Document;

public class Cadastro {
    private String uid;
    private String nome;
    private String email;
    private String codigo;
    private String tipo;

    public Cadastro() {}

    public boolean criarDocumento() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> colecao = db.getCollection("users");

            Document usuario = new Document("uid", this.uid)
                    .append("nome", this.nome)
                    .append("email", this.email)
                    .append("tipo", this.tipo)
                    .append("codigo", this.codigo);



            colecao.insertOne(usuario);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}


