package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Projections;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;
import src.domain.AlunoSimples;

import java.util.ArrayList;
import java.util.List;

public class GetAlunosSimples {
    private String turmaId;

    public GetAlunosSimples(String turmaId) {
        this.turmaId = turmaId;
    }

    public List<AlunoSimples> getStudents(){
        if(this.turmaId == null){
            return null;
        }

        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try(MongoClient client = MongoClients.create(uri)){
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> turmas = db.getCollection("turmas");
            MongoCollection<Document> users = db.getCollection("users");

            Document turma = turmas.find(Filters.eq("_id", new ObjectId(turmaId))).first();
            if (turma == null) {
                return null; // Turma não encontrada
            }

            List<ObjectId> alunosIds = turma.getList("alunos", ObjectId.class);
            if (alunosIds == null || alunosIds.isEmpty()) {
                return new ArrayList<>(); // Turma sem alunos
            }

            List<AlunoSimples> alunos = new ArrayList<>();
            for (Document doc : users.find(Filters.in("_id", alunosIds))
                    .projection(Projections.fields( // projection para buscar apenas campos necessarios
                            Projections.include("nome", "email"),
                            Projections.excludeId()
                    ))) {

                AlunoSimples aluno = new AlunoSimples(
                        doc.getString("nome"),
                        doc.getString("email")
                );
                alunos.add(aluno);
            }

            return alunos;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String toString(){return "" + this.turmaId;}

    @Override
    public boolean equals(Object obj){
        if (obj == this) return true;
        if(obj == null) return false;
        if(this.getClass() != obj.getClass()) return false;
        GetAlunosSimples g = (GetAlunosSimples) obj;
        return this.turmaId.equals(g.turmaId);
    }

    @Override
    public int hashCode(){return this.turmaId.hashCode();}

}
