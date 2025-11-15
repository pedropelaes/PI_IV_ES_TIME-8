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

public class EditarChamada {
    private String codigoChamada;
    private List<Presenca> presentesEditados;

    public EditarChamada(String codigoChamada, List<Presenca> presentes){
        this.codigoChamada = codigoChamada;
        this.presentesEditados = presentes;
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

            // calculo do limite da edicao da presenca ( 14 dias)
            Instant agora = Instant.now();
            Instant limite = agora.minus(14, ChronoUnit.DAYS);
            Date dataLimite = Date.from(limite);

            List<WriteModel<Document>> operations = new ArrayList<>();

            for (Presenca p : this.presentesEditados){
                Bson filter = Filters.and(
                        Filters.eq("_id", new ObjectId(this.codigoChamada)),
                        Filters.gte("dataAbertura", dataLimite) // Só permite se dataAbertura for >= dataLimite
                );

                Bson update = Updates.combine(
                        Updates.set("presentes.$[elem].presente", p.getPresente()),
                        Updates.set("atualizadoEm", new Date()) // Adiciona a data/hora atual
                );
                UpdateOptions options = new UpdateOptions().arrayFilters(
                        List.of(
                                Filters.eq("elem.alunoId", new ObjectId(p.getAlunoId()))
                        )
                );
                operations.add(new UpdateOneModel<>(filter, update, options));
            }
            if (!operations.isEmpty()) {
                // ordered(false) permite que o MongoDB execute as atualizações
                // em paralelo (se possível) para maior eficiência.
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
