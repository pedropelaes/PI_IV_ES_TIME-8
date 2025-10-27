package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;
import src.domain.Turma;
import io.github.cdimascio.dotenv.Dotenv;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class GetTurmas {
    private String operacao;
    private List<String> turmasId;

    public GetTurmas(){}
    public GetTurmas(String operacao, List<String> turmasId) {
        this.operacao = operacao;
        this.turmasId = turmasId;
    }

    public List<Turma> getTurmas() {
        if(this.turmasId == null){
            return null;
        }
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        List<Turma> turmas = new ArrayList<>();

        try(MongoClient client = MongoClients.create(uri)){
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> colecao = db.getCollection("turmas");

            List<ObjectId> objectIds = this.turmasId.stream().map(ObjectId::new).collect(Collectors.toList());

            Bson filter = Filters.in("_id", objectIds);

            for(Document doc : colecao.find(filter)){
                List<ObjectId> alunosIds = doc.getList("alunos", ObjectId.class, new ArrayList<>());
                List<String> alunos = alunosIds.stream().map(ObjectId::toHexString).collect(Collectors.toList());

                Turma turma = new Turma(
                        doc.getObjectId("_id").toHexString(),
                        doc.getString("nome"),
                        doc.getString("descricao"),
                        doc.getString("codigo"),
                        doc.getObjectId("professorId").toHexString(),
                        alunos,
                        doc.getDate("criadoEm"),
                        doc.getDate("atualizadoEm")
                );
                turmas.add(turma);
            }

            return turmas;
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

}
