package src.protocol.requests;

import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import com.mongodb.client.*;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.time.Instant;
import java.util.ArrayList;
import java.util.UUID;

public class AbrirChamada {
    private String aulaId;      // _id da aula (string enviada pelo app)
    private double latitude;
    private double longitude;
    private String operacao;

    public AbrirChamada() {}

    public AbrirChamada(String aulaId, double latitude, double longitude, String operacao) {
        this.aulaId = aulaId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.operacao = operacao;
    }

    public String abrir() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = db.getCollection("aulas");

            // Procura a aula pelo _id
            if (aulaId == null || aulaId.isEmpty()) {
                System.out.println("Erro: aulaId está null ou vazio!");
                return null;
            }

            if (aulaId == null || aulaId.isEmpty()) {
                System.out.println("Erro: aulaId está null ou vazio!");
                return null;
            }

            Document aula = aulas.find(Filters.eq("codigoTurma", aulaId)).first();

            if (aula == null) {
                System.out.println("Aula não encontrada!");
                return null;
            }


            if (aula == null) {
                System.out.println("Aula não encontrada!");
                return null;
            }

            if (aula == null) {
                System.out.println("Aula não encontrada!");
                return null;
            }

            // Gera um código único para a chamada
            String codigoChamada = "CHAMADA-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();

            // Cria o documento de chamada
            Document chamada = new Document()
                    .append("codigo", codigoChamada)
                    .append("aberta", true)
                    .append("latitude", latitude)
                    .append("longitude", longitude)
                    .append("dataAbertura", Instant.now().toString())
                    .append("presentes", new ArrayList<>());

            // Atualiza a aula
            aulas.updateOne(
                    Filters.eq("_id", new ObjectId(aulaId)),
                    Updates.combine(
                            Updates.set("chamada", chamada),
                            Updates.set("atualizadoEm", Instant.now().toString())
                    )
            );

            System.out.println("Chamada aberta com sucesso! Código: " + codigoChamada);
            return codigoChamada; // retorna o código pra ser transformado em QR Code
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String toString() {
        return operacao + " " + aulaId + " " + latitude + " " + longitude;
    }
}


