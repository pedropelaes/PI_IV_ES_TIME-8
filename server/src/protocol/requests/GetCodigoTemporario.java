package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import dev.samstevens.totp.code.CodeGenerator;
import dev.samstevens.totp.code.DefaultCodeGenerator;
import dev.samstevens.totp.code.HashingAlgorithm;
import dev.samstevens.totp.time.SystemTimeProvider;
import dev.samstevens.totp.time.TimeProvider;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;

public class GetCodigoTemporario {
    private String codigoChamada;
    public GetCodigoTemporario(String codigoChamada){
        this.codigoChamada = codigoChamada;
    }

    public String getCodigo(){
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try(MongoClient mongoClient = MongoClients.create(uri)){
            MongoDatabase database = mongoClient.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = database.getCollection("aulas");

            Document aula = aulas.find(Filters.eq("codigo", this.codigoChamada)).first();

            if(aula == null || !aula.getBoolean("aberta", false)){
                return null;
            }

            String chaveTOTP = aula.getString("chaveTOTP");
            if(chaveTOTP == null){
                return null;
            }

            TimeProvider timeProvider = new SystemTimeProvider();
            CodeGenerator codeGenerator = new DefaultCodeGenerator(HashingAlgorithm.SHA1, 6);
            long counter = (timeProvider.getTime() - 0) / 15; // 15 segundos

            return codeGenerator.generate(chaveTOTP, counter);
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

    public String getCodigoChamada() { return codigoChamada; }
}
