package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Updates;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;

import java.util.List;
import java.util.Objects;

import static com.mongodb.client.model.Filters.*;

public class ApagarTurma {
    private String turmaId;
    private String professorId;

    public ApagarTurma(String turmaId, String professorId) {
        this.turmaId = turmaId;
        this.professorId = professorId;
    }

    public String getTurmaId() {
        return turmaId;
    }
    public String getProfessorId() {
        return professorId;
    }

    public boolean apagarTurma() {
        if(this.turmaId == null || this.professorId == null){
            return false;
        }
        Dotenv dotenv = Dotenv.load();
        String uir = dotenv.get("MONGO_URI");
        try (MongoClient client = MongoClients.create(uir)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> turmas = db.getCollection("turmas");
            MongoCollection<Document> users = db.getCollection("users");

            ObjectId turmaId = new ObjectId(this.turmaId);
            ObjectId professorId = new ObjectId(this.professorId);

            Bson filter = and(
                    eq("_id", turmaId),
                    eq("professorId", professorId)
            );

            Document turmaApagada = turmas.findOneAndDelete(filter);

            if (turmaApagada != null) {
                Bson filterProfessor = eq("_id", professorId);
                Bson updateProfessor = Updates.pull("turmas", this.turmaId);
                users.updateOne(filterProfessor, updateProfessor);

                List<ObjectId> alunosIds = turmaApagada.getList("alunos", ObjectId.class);
                if (alunosIds != null && !alunosIds.isEmpty()) {
                    Bson filterAlunos = in("_id", alunosIds);
                    Bson updateAlunos = Updates.pull("turmas", this.turmaId);
                    users.updateMany(filterAlunos, updateAlunos);
                }

                return true;
            } else {
                return false; // Falha, não apagou
            }
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String toString() {return "TurmaID: " + this.turmaId + "ProfessorID: " + this.professorId;}

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 2 * ret + this.turmaId.hashCode();
        ret = 2 * ret + this.professorId.hashCode();
        return ret;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        ApagarTurma a = (ApagarTurma) obj;
        if (!this.turmaId.equals(a.turmaId) || !this.professorId.equals(a.professorId)) return false;
        return true;
    }

}
