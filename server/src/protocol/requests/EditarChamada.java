package src.protocol.requests;

import com.mongodb.bulk.BulkWriteResult;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.*;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;
import src.domain.Presenca;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Objects;

public class EditarChamada {
    private String codigoChamada;
    private List<Presenca> presentesEditados;

    public EditarChamada(String codigoChamada, List<Presenca> presentes){
        this.codigoChamada = codigoChamada;
        this.presentesEditados = presentes;
    }

    public String getCodigoChamada() {return codigoChamada;}
    public List<Presenca> getPresentesEditados() {return presentesEditados;}
    public void setCodigoChamada(String codigoChamada) {this.codigoChamada = codigoChamada;}
    public void setPresentesEditados(List<Presenca> presentesEditados) {this.presentesEditados = presentesEditados;}

    @Override
    public String toString() {
        return "codigoChamada: " + this.codigoChamada +
                "\n presentesEditados: " + this.presentesEditados;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        EditarChamada that = (EditarChamada) obj;

        if (!Objects.equals(codigoChamada, that.codigoChamada)) return false;
        if (!Objects.equals(presentesEditados, that.presentesEditados)) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 31 * ret + Objects.hashCode(this.codigoChamada);
        ret = 31 * ret + Objects.hashCode(this.presentesEditados);
        return ret;
    }

    public boolean editar(){
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)){
            if(this.codigoChamada == null || this.presentesEditados == null || this.presentesEditados.isEmpty()){
                return false;
            }
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = db.getCollection("aulas");

            Instant agora = Instant.now();
            Instant limite = agora.minus(14, ChronoUnit.DAYS);
            Date dataLimite = Date.from(limite);

            List<WriteModel<Document>> operations = new ArrayList<>();

            for (Presenca p : this.presentesEditados){
                Bson filter = Filters.and(
                        Filters.eq("_id", new ObjectId(this.codigoChamada)),
                        Filters.gte("dataAbertura", dataLimite)
                );

                Bson update = Updates.combine(
                        Updates.set("presentes.$[elem].presente", p.getPresente()),
                        Updates.set("atualizadoEm", new Date())
                );
                UpdateOptions options = new UpdateOptions().arrayFilters(
                        List.of(
                                Filters.eq("elem.alunoId", new ObjectId(p.getAlunoId()))
                        )
                );
                operations.add(new UpdateOneModel<>(filter, update, options));
            }
            if (!operations.isEmpty()) {
                BulkWriteResult result = aulas.bulkWrite(operations, new BulkWriteOptions().ordered(false));
                return result.getModifiedCount() > 0;
            }

            return true;
        }catch(Exception e){
            e.printStackTrace();
            return false;
        }
    }

}