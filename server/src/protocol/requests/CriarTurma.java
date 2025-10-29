package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

public class CriarTurma {
    private String nome;
    private String descricao;
    private String operacao;
    private String objectId;


    public CriarTurma(){}

    public static String gerarCodigo(String nomeDaTurma) {
        if (nomeDaTurma == null || nomeDaTurma.trim().isEmpty()) {
            throw new IllegalArgumentException("O nome da turma não pode ser vazio.");
        }

        String prefixo = nomeDaTurma.trim()
                .replaceAll("[^a-zA-Z]", "")
                .substring(0, Math.min(nomeDaTurma.length(), 4))
                .toUpperCase();

        LocalDate hoje = LocalDate.now();
        int ano = hoje.getYear();
        int semestre = (hoje.getMonthValue() <= 6) ? 1 : 2;

        String sufixoUnico = UUID.randomUUID()
                .toString()
                .substring(0, 5)
                .toUpperCase();

        return String.format("%s-%d-%d-%s", prefixo, ano, semestre, sufixoUnico);
    }

    public boolean criarTurma(){
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> colecao = db.getCollection("turmas");
            MongoCollection<Document> usersCol = db.getCollection("users");


            ObjectId professorObjectId = new ObjectId(objectId);
            Document professor = usersCol.find(Filters.eq("_id", professorObjectId)).first();

            Document turma = new Document("nome", this.nome)
                    .append("descricao", this.descricao)
                    .append("professorId", new ObjectId())
                    .append("codigo", gerarCodigo(this.nome))
                    .append("alunos", new ArrayList<ObjectId>())
                    .append("aulas", new ArrayList<ObjectId>())
                    .append("criadoEm", new Date())
                    .append("atualizadoEm", new Date());

            colecao.insertOne(turma);
            ObjectId turmaId = turma.getObjectId("_id");

            usersCol.updateOne(
                    Filters.eq("_id", professorObjectId),
                    Updates.push("turmas", turmaId)
            );

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String toString() {
        return "src.protocol.requests.CriarTurma{" +
                "turma = " + nome +
                ", operacao='" + operacao + '\'' +
                '}';
    }
}
