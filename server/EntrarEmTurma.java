import io.github.cdimascio.dotenv.Dotenv;
import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import org.bson.Document;
import org.bson.types.BasicBSONList;
import org.bson.types.ObjectId;

import java.util.List;

public class EntrarEmTurma {
    private String objectId;
    private String codigoTurma;
    private String operacao;

    public EntrarEmTurma() {}

    public EntrarEmTurma(String objectId, String codigoTurma, String operacao) {
        this.objectId = objectId;
        this.codigoTurma = codigoTurma;
        this.operacao = operacao;
    }

    public boolean entrar() {
        if (objectId == null || codigoTurma == null) {
            System.out.println("Dados incompletos para entrar na turma.");
            return false;
        }

        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> turmas = db.getCollection("turmas");

            Document turma = turmas.find(Filters.eq("codigo", codigoTurma)).first();

            if (turma == null) {
                System.out.println("Turma não encontrada: " + codigoTurma);
                return false;
            }

            List<ObjectId> alunos = (List<ObjectId>) turma.get("alunos");
            ObjectId objId = new  ObjectId(objectId);
            if (alunos != null && alunos.contains(objId)) {
                System.out.println("Aluno já está na turma.");
                return false;
            }

            // Adiciona o aluno à lista de alunos
            turmas.updateOne(
                    Filters.eq("codigo", codigoTurma),
                    Updates.push("alunos", objId)
            );

            System.out.println("Aluno adicionado à turma com sucesso!");
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String toString() {
        return this.operacao + " aluno " + this.objectId + " entrou na turma " + this.codigoTurma;
    }
}
