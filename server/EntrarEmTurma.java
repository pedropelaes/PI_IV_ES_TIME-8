import io.github.cdimascio.dotenv.Dotenv;
import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import org.bson.Document;
import org.bson.types.BasicBSONList;

public class EntrarEmTurma {
    private String alunoUid;
    private String codigoTurma;
    private String operacao;

    public EntrarEmTurma() {}

    public EntrarEmTurma(String alunoUid, String codigoTurma, String operacao) {
        this.alunoUid = alunoUid;
        this.codigoTurma = codigoTurma;
        this.operacao = operacao;
    }

    public boolean entrar() {
        if (alunoUid == null || codigoTurma == null) {
            System.out.println("Dados incompletos para entrar na turma.");
            return false;
        }

        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> turmas = db.getCollection("turmas");

            // Busca a turma pelo código
            Document turma = turmas.find(Filters.eq("codigo", codigoTurma)).first();

            if (turma == null) {
                System.out.println("Turma não encontrada: " + codigoTurma);
                return false;
            }

            // Verifica se o aluno já está na turma
            BasicBSONList alunos = (BasicBSONList) turma.get("alunos");
            if (alunos != null && alunos.contains(alunoUid)) {
                System.out.println("Aluno já está na turma.");
                return false;
            }

            // Adiciona o aluno à lista de alunos
            turmas.updateOne(
                    Filters.eq("codigo", codigoTurma),
                    Updates.push("alunos", alunoUid)
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
        return this.operacao + " aluno " + this.alunoUid + " entrou na turma " + this.codigoTurma;
    }
}
