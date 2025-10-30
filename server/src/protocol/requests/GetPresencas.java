package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.util.ArrayList;
import java.util.List;

public class GetPresencas {
    private String codigoChamada;
    private String turmaId;
    private String operacao;

    public GetPresencas() {}

    public List<String> getPresencas() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = db.getCollection("aulas");
            MongoCollection<Document> users = db.getCollection("users");

            Document aula = null;

            // Se codigoChamada foi fornecido, usa ele
            if (codigoChamada != null && !codigoChamada.isEmpty()) {
                aula = aulas.find(Filters.eq("codigo", codigoChamada)).first();
            } 
            // Se não, mas tem turmaId, busca a última chamada fechada da turma
            else if (turmaId != null && !turmaId.isEmpty()) {
                aula = aulas.find(Filters.and(
                    Filters.eq("turmaId", new ObjectId(turmaId)),
                    Filters.eq("aberta", false)
                ))
                .sort(Sorts.descending("dataFechamento"))
                .first();
                
                // Se não encontrou chamada fechada, busca a última chamada (aberta ou fechada)
                if (aula == null) {
                    aula = aulas.find(Filters.eq("turmaId", new ObjectId(turmaId)))
                        .sort(Sorts.descending("dataAbertura"))
                        .first();
                }
            }

            if (aula == null) {
                System.out.println("Aula não encontrada.");
                return new ArrayList<>();
            }


            // Pega a lista de ObjectIds dos alunos presentes
            List<ObjectId> presentesIds = aula.getList("presentes", ObjectId.class, new ArrayList<>());

            if (presentesIds.isEmpty()) {
                System.out.println("Nenhum aluno presente encontrado.");
                return new ArrayList<>();
            }

            // Busca os nomes dos alunos pelos IDs
            List<String> alunosNomes = new ArrayList<>();
            for (ObjectId alunoId : presentesIds) {
                Document aluno = users.find(Filters.eq("_id", alunoId)).first();
                if (aluno != null) {
                    alunosNomes.add(aluno.getString("nome"));
                }
            }

            System.out.println("Encontrados " + alunosNomes.size() + " alunos presentes.");
            return alunosNomes;
        } catch (Exception e) {
            System.err.println("Erro ao buscar presenças: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public String getCodigoChamada() {
        return codigoChamada;
    }

    public void setCodigoChamada(String codigoChamada) {
        this.codigoChamada = codigoChamada;
    }

    public String getOperacao() {
        return operacao;
    }

    public void setOperacao(String operacao) {
        this.operacao = operacao;
    }

    public String getTurmaId() {
        return turmaId;
    }

    public void setTurmaId(String turmaId) {
        this.turmaId = turmaId;
    }
}

