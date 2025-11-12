package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.*;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.conversions.Bson;
import src.domain.Presenca;

import java.util.ArrayList;
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

            List<WriteModel<Document>> operations = new ArrayList<>();

            for (Presenca p : this.presentesEditados){
                Bson filter = Filters.eq("codigo", this.codigoChamada);

                Bson update = Updates.set("presentes.$[elem].presente", p.getPresente());
                UpdateOptions options = new UpdateOptions().arrayFilters(
                        List.of(
                                // Ajuste "elem.alunoId" se o nome do campo no DB for diferente
                                // Ajuste "p.getAlunoId()" se o método no seu POJO for diferente
                                Filters.eq("alunoId", p.getAlunoId())
                        )
                );
                operations.add(new UpdateOneModel<>(filter, update, options));
            }
            if (!operations.isEmpty()) {
                // ordered(false) permite que o MongoDB execute as atualizações
                // em paralelo (se possível) para maior eficiência.
                aulas.bulkWrite(operations, new BulkWriteOptions().ordered(false));
            }

            return true;
        }catch(Exception e){
            e.printStackTrace();
            return false;
        }
    }
    
}
