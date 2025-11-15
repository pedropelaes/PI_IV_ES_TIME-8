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
import src.domain.Aula;
import src.domain.Presenca;
import src.domain.User;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

public class GetAulas {
    private String turmaId;

    public GetAulas(){}
    public GetAulas(String turmaId) {
        this.turmaId = turmaId;
    }

    public List<Aula> getAulasFromTurma(){
        List<Aula> aulas = new ArrayList<>();

        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");
        try(MongoClient client = MongoClients.create(uri)){
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> colecao = db.getCollection("aulas");


            for (Document doc : colecao.find(Filters.eq("turmaId", new ObjectId(this.turmaId)))
                    .sort(Sorts.descending("dataAbertura"))){
                List<Presenca> listaDePresenca = new ArrayList<>();
                List<Document> presentesDocs = doc.getList("presentes", Document.class);

                if (presentesDocs != null) {
                    for (Document presencaDoc : presentesDocs) {
                        String alunoId = presencaDoc.getObjectId("alunoId").toHexString();
                        String nome = presencaDoc.getString("nome");
                        boolean presente = presencaDoc.getBoolean("presente", false);
                        listaDePresenca.add(new Presenca(alunoId, nome, presente));
                    }
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
                        listaDePresenca,
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

    @Override
    public String toString(){return "" + this.turmaId;}

    @Override
    public boolean equals(Object obj){
        if(obj == this) return true;
        if (obj == null || obj.getClass() != this.getClass()) return false;
        GetAulas g = (GetAulas) obj;
        if (!this.turmaId.equals(g.turmaId)) return false;
        return true;
    }

    @Override
    public int hashCode(){
        int ret = 1;
        ret = ret * 31 + this.turmaId.hashCode();
        if(ret < 0) ret=-ret;
        return ret;
    }

}
