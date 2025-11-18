package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;

public class DeletarChamada {
    private String codigoChamada;

    public DeletarChamada() {}

    public DeletarChamada(String codigoChamada){
        this.codigoChamada = codigoChamada;
    }

    public String getCodigoChamada() {
        return codigoChamada;
    }

    public void setCodigoChamada(String codigoChamada) {
        this.codigoChamada = codigoChamada;
    }

    public boolean deletar(){
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)){
            if(this.codigoChamada == null || this.codigoChamada.isEmpty()){
                return false;
            }
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = db.getCollection("aulas");
            MongoCollection<Document> turmas = db.getCollection("turmas");

            // Busca a chamada primeiro para verificar a data
            Document chamada = aulas.find(Filters.eq("_id", new ObjectId(this.codigoChamada))).first();
            
            if(chamada == null){
                return false; // Chamada não encontrada
            }

            // Calcula o limite de deleção (7 dias atrás)
            Instant agora = Instant.now();
            Instant limite = agora.minus(7, ChronoUnit.DAYS);
            Date dataLimite = Date.from(limite);

            // Obtém a data de abertura da chamada
            Date dataAbertura = chamada.getDate("dataAbertura");
            
            // Verifica se a chamada foi criada há menos de 7 dias
            // Se dataAbertura é anterior ao limite, significa que tem mais de 7 dias
            if(dataAbertura.before(dataLimite)){
                return false; // Chamada tem mais de 7 dias, não pode ser deletada
            }

            // Deleta a chamada
            Document chamadaDeletada = aulas.findOneAndDelete(
                Filters.eq("_id", new ObjectId(this.codigoChamada))
            );

            if(chamadaDeletada != null){
                // Remove a referência da chamada na turma
                ObjectId turmaId = chamadaDeletada.getObjectId("turmaId");
                if(turmaId != null){
                    Bson filter = Filters.eq("_id", turmaId);
                    Bson update = Updates.pull("aulas", new ObjectId(this.codigoChamada));
                    turmas.updateOne(filter, update);
                }
                return true;
            }

            return false;
        }catch(Exception e){
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public String toString() {
        return "DeletarChamada{codigoChamada='" + codigoChamada + "'}";
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        DeletarChamada that = (DeletarChamada) obj;
        return codigoChamada != null ? codigoChamada.equals(that.codigoChamada) : that.codigoChamada == null;
    }

    @Override
    public int hashCode() {
        return codigoChamada != null ? codigoChamada.hashCode() : 0;
    }
}

