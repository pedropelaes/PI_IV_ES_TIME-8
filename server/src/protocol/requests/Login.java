package src.protocol.requests;

import com.mongodb.client.model.Filters;
import io.github.cdimascio.dotenv.Dotenv;
import com.mongodb.client.*;
import org.bson.Document;
import org.bson.types.ObjectId;
import src.domain.User;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;


public class Login {
    private String uid;
    private String operacao;

    public Login() {}

    public Login(String uid, String operacao) {
        this.uid = uid;
        this.operacao = operacao;
    }

    public User getUserData(){
        if(this.uid == null){
            return null;
        }

        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");
        try(MongoClient client = MongoClients.create(uri)){
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> colecao = db.getCollection("users");

            Document doc = colecao.find(Filters.eq("uid", this.uid)).first();
            if(doc == null){return null;}

            List<ObjectId> turmasIds = doc.getList("turmas", ObjectId.class, new ArrayList<>());
            List<String> turmas = turmasIds.stream()
                    .map(ObjectId::toHexString)
                    .collect(Collectors.toList());

            User user = new User(
                    doc.getObjectId("_id").toHexString(),
                doc.getString("uid"),
                doc.getString("nome"),
                doc.getString("email"),
                doc.getString("tipo"),
                doc.getString("codigo"),
                doc.getString("faceToken"),
                turmas
            );


            return user;
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String toString() {
        return this.operacao + " " + this.uid;
    }

    @Override
    public boolean equals(Object obj) {
        if(obj == this) return true;
        if(obj == null) return false;
        if(obj.getClass() != this.getClass()) return false;
        Login l = (Login)obj;
        if (!this.uid.equals(l.uid) || !this.operacao.equals(l.operacao)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 31 + this.uid.hashCode();
        ret = ret * 31 + this.operacao.hashCode();
        return ret;
    }

}
