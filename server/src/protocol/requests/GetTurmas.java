package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;
import src.domain.LocPadrao;
import src.domain.Turma;
import io.github.cdimascio.dotenv.Dotenv;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
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

                Document locDoc = doc.get("localizacaoPadrao", Document.class);
                LocPadrao locPadrao = null;
                if(locDoc != null){
                    locPadrao = new LocPadrao(
                            locDoc.getDouble("latitude"),
                            locDoc.getDouble("longitude")
                    );
                }

                Date criadoEm = null;
                Object criadoObj = doc.get("criadoEm");

                if (criadoObj instanceof Date) {
                    criadoEm = (Date) criadoObj;
                } else if (criadoObj instanceof String) {
                    try {
                        // ajuste o formato conforme como a string está salva
                        criadoEm = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSX").parse((String) criadoObj);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }

                // converter atualizadoEm
                Date atualizadoEm = null;
                Object atualizadoObj = doc.get("atualizadoEm");
                if (atualizadoObj instanceof Date) {
                    atualizadoEm = (Date) atualizadoObj;
                } else if (atualizadoObj instanceof String) {
                    try {
                        atualizadoEm = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSX").parse((String) atualizadoObj);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }

                Turma turma = new Turma(
                        doc.getObjectId("_id").toHexString(),
                        doc.getString("nome"),
                        doc.getString("descricao"),
                        doc.getString("codigo"),
                        doc.getObjectId("professorId").toHexString(),
                        alunos,
                        criadoEm,
                        atualizadoEm,
                        locPadrao
                );
                turmas.add(turma);
            }

            return turmas;
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String toString() {return "TurmasID: " + this.turmasId.toString() + " " + this.operacao;}

    @Override
    public boolean equals(Object obj){
        if (this ==  obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        GetTurmas g = (GetTurmas) obj;
        if (!this.turmasId.equals(g.turmasId) || !this.operacao.equals(g.operacao)) return false;
        return true;
    }

    @Override
    public int hashCode(){
        int ret = 1;
        ret = ret * 31 + this.turmasId.hashCode();
        ret = ret * 31 + this.operacao.hashCode();
        return ret;
    }

}
