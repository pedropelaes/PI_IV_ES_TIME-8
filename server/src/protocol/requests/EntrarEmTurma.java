package src.protocol.requests;

import io.github.cdimascio.dotenv.Dotenv;
import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import org.bson.Document;
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
            try (ClientSession clientSession = client.startSession()) {

                return clientSession.withTransaction(() -> {
                    MongoDatabase db = client.getDatabase("vocattio_db");
                    MongoCollection<Document> turmasCollection = db.getCollection("turmas");
                    MongoCollection<Document> usersCollection = db.getCollection("users");

                    Document turma = turmasCollection.find(clientSession, Filters.eq("codigo", codigoTurma)).first();

                    if (turma == null) {
                        System.out.println("Turma não encontrada com o código: " + codigoTurma);
                        return false;
                    }

                    ObjectId turmaId = turma.getObjectId("_id");
                    ObjectId alunoId = new ObjectId(objectId);

                    List<ObjectId> alunos = turma.getList("Alunos", ObjectId.class);
                    if (alunos != null && alunos.contains(alunoId)) {
                        System.out.println("Aluno já está na turma.");
                        return false;
                    }

                    turmasCollection.updateOne(clientSession,
                            Filters.eq("_id", turmaId),
                            Updates.push("alunos", alunoId)
                    );

                    usersCollection.updateOne(clientSession,
                            Filters.eq("_id", alunoId),
                            Updates.push("turmas", turmaId)
                    );

                    System.out.println("Aluno adicionado à turma e turma adicionada ao aluno com sucesso!");
                    return true;
                });
            }
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
