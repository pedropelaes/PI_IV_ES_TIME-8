package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import com.mongodb.client.result.UpdateResult;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;
import src.domain.LocPadrao;

public class EditarTurma {
    private String turmaId;
    private String nome;
    private String descricao;
    private LocPadrao locPadrao;

    public EditarTurma(String turmaId, String nome, String descricao, LocPadrao locPadrao) {
        this.turmaId = turmaId;
        this.nome = nome;
        this.descricao = descricao;
        this.locPadrao = new LocPadrao(locPadrao);
    }

    public boolean editarTurma(){
        if(this.turmaId == null || this.nome == null || this.descricao == null || this.locPadrao == null){
            return false;
        }

        Dotenv dotenv = Dotenv.load();
        String uir = dotenv.get("MONGO_URI");
        try (MongoClient client = MongoClients.create(uir)){
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> turmas = db.getCollection("turmas");

            ObjectId turmaId = new ObjectId(this.turmaId);
            Bson filter = Filters.eq("_id", turmaId);

            Document locDocument = new Document()
                    .append("latitude", this.locPadrao.getLatitude())
                    .append("longitude", this.locPadrao.getLongitude());

            Bson updates = Updates.combine(
                    Updates.set("nome", this.nome),
                    Updates.set("descricao", this.descricao),
                    Updates.set("locPadrao", locDocument)
            );

            UpdateResult result = turmas.updateOne(filter, updates);

            return result.getModifiedCount() > 0;
        }catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String toString(){return "TurmaID: " + this.turmaId + "Nome: " + this.nome + "Descricao: " + this.descricao +  "LocPadrao: " + this.locPadrao;}

    @Override
    public boolean equals(Object obj){
        if (obj == this) return true;
        if (obj == null) return false;
        if (obj.getClass() != this.getClass()) return false;
        EditarTurma e = (EditarTurma) obj;
        if (!this.turmaId.equals(e.turmaId) || !this.nome.equals(e.nome)
                || !this.descricao.equals(e.descricao) || !this.locPadrao.equals(e.locPadrao)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 31 + this.turmaId.hashCode();
        ret = ret * 31 + this.nome.hashCode();
        ret = ret * 31 + this.descricao.hashCode();
        ret = ret * 31 + this.locPadrao.hashCode();
        return ret;
    }

}
