package src.protocol.requests;

import io.github.cdimascio.dotenv.Dotenv;
import com.mongodb.client.*;
import org.bson.Document;

import java.util.ArrayList;

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
                    .append("codigo", this.codigo)
                    .append("turmas", new ArrayList<>());



            colecao.insertOne(usuario);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String toString() {return "UID: " + this.uid + ", Nome: " + this.nome + ", Email: " + this.email +
                                ", Codigo: " + this.codigo + ", Tipo: " + this.tipo;}

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        Cadastro c = (Cadastro) obj;
        if (!this.uid.equals(c.uid) || !this.nome.equals(c.nome) ||
                !this.codigo.equals(c.codigo) || !this.email.equals(c.email) ||
                !this.tipo.equals(c.tipo)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 2 + this.uid.hashCode();
        ret = ret * 2 + this.nome.hashCode();
        ret = ret * 2 + this.email.hashCode();
        ret = ret * 2 + this.codigo.hashCode();
        ret = ret * 2 + this.tipo.hashCode();
        return ret;
    }

}


