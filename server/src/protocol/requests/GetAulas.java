package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;
import src.domain.Aula;
import src.domain.User;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

public class GetAulas {
    private String turmaId;
    private String operacao;

    public GetAulas(){}
    public GetAulas(String turmaId, String operacao) {
        this.turmaId = turmaId;
        this.operacao = operacao;
    }

    public List<Aula> getAulasFromTurma(){
        List<Aula> aulas = new ArrayList<>();

        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");
        try(MongoClient client = MongoClients.create(uri)){
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> colecao = db.getCollection("aulas");


            for (Document doc : colecao.find(Filters.eq("turmaId", new ObjectId(this.turmaId)))){
                List<String> presentesIds = new ArrayList<>();
                List<ObjectId> objectIdList = doc.getList("presentes", ObjectId.class);
                if (objectIdList != null) {
                    presentesIds = objectIdList.stream()
                            .map(ObjectId::toString)
                            .collect(Collectors.toList());
                }

                Date dataAbertura = null;
                Object dataAberturaObj = doc.get("dataAbertura");

                if (dataAberturaObj instanceof Date) {
                    dataAbertura = (Date) dataAberturaObj;
                } else if (dataAberturaObj instanceof String) {
                    try {
                        dataAbertura = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSX").parse((String) dataAberturaObj);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }

                Date dataFechamento = null;
                Object dataFechamentoObj = doc.get("dataFechamento");
                if (dataFechamentoObj instanceof Date) {
                    dataFechamento = (Date) dataFechamentoObj;
                } else if (dataFechamentoObj instanceof String) {
                    try {
                        dataFechamento = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSX").parse((String) dataFechamentoObj);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }


                Aula aula = new Aula(
                        doc.getObjectId("_id").toHexString(),
                        doc.getObjectId("turmaId").toHexString(),
                        doc.getString("codigo"),
                        doc.getBoolean("aberta"),
                        doc.getDouble("latitude"),
                        doc.getDouble("longitude"),
                        dataAbertura,
                        presentesIds,
                        dataFechamento
                );
                aulas.add(aula);
            }

            return aulas;
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }
}
