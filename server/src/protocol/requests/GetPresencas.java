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
    private String chamadaId;
    private String operacao;

    public GetPresencas() {}

    public List<String> getPresencas() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");
        if(this.chamadaId == null){
            return null;
        }

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = db.getCollection("aulas");
            MongoCollection<Document> users = db.getCollection("users");

            Document doc = aulas.find(Filters.eq("_id", new ObjectId(this.chamadaId))).first();
            if(doc == null) return null;

            List<ObjectId> presentesIds = doc.getList("presentes", ObjectId.class, new ArrayList<>());

            if (presentesIds.isEmpty()) {
                System.out.println("Nenhum aluno presente encontrado.");
                return null;
            }

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


    public String getOperacao() {
        return operacao;
    }

    public void setOperacao(String operacao) {
        this.operacao = operacao;
    }

    @Override
    public String toString(){return "ChamadaID: " + this.chamadaId + " - " + this.operacao;}

    @Override
    public boolean equals(Object obj){
        if (obj == this) return true;
        if (obj == null || obj.getClass() != this.getClass()) return false;
        GetPresencas g = (GetPresencas) obj;
        if (!this.chamadaId.equals(g.chamadaId) || !this.operacao.equals(g.operacao)) return false;
        return true;
    }

    @Override
    public int hashCode(){
        int ret = 1;
        ret = ret * 31 + this.chamadaId.hashCode();
        ret = ret * 31 + this.operacao.hashCode();
        return ret;
    }

}

