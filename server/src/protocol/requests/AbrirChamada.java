package src.protocol.requests;

import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import com.mongodb.client.*;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

public class AbrirChamada {
    private String codigoTurma;      // _id da aula (string enviada pelo app)
    private double latitude;
    private double longitude;
    private String operacao;

    public AbrirChamada() {}

    public AbrirChamada(String codigoTurma, double latitude, double longitude, String operacao) {
        this.codigoTurma = codigoTurma;
        this.latitude = latitude;
        this.longitude = longitude;
        this.operacao = operacao;
    }

    public String abrir() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> turmas = db.getCollection("turmas");
            MongoCollection<Document> aulas = db.getCollection("aulas");

            // Procura a turma pelo _id
            if (codigoTurma == null || codigoTurma.isEmpty()) {
                System.out.println("Erro: codigoTurma está null ou vazio!");
                return null;
            }

            Document turma = turmas.find(Filters.eq("_id", new ObjectId(codigoTurma))).first();

            if (turma == null) {
                System.out.println("Turma não encontrada!");
                return null;
            }

            ArrayList<ObjectId> alunosIds = turma.get("alunos", ArrayList.class);

            // 3. [NOVO] Cria a lista de presença (o "snapshot")
            ArrayList<Document> listaPresenca = new ArrayList<>();
            if (alunosIds != null) {
                for (ObjectId alunoId : alunosIds) {
                    listaPresenca.add(new Document("alunoId", alunoId)
                            .append("presente", false)
                    );
                }
            }

            // Gera um código único para a chamada
            String codigoChamada = "CHAMADA-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();

            // Cria o documento de aula
            Document aula = new Document()
                    .append("turmaId", new ObjectId(codigoTurma))
                    .append("codigo", codigoChamada)
                    .append("aberta", true)
                    .append("latitude", latitude)
                    .append("longitude", longitude)
                    .append("dataAbertura", new Date())
                    .append("presentes", listaPresenca);

            aulas.insertOne(aula);

            // Atualiza a turma
            turmas.updateOne(
                    Filters.eq("_id", new ObjectId(codigoTurma)),
                    Updates.combine(
                            Updates.push("aulas", aula.getObjectId("_id")),
                            Updates.set("atualizadoEm", new Date())
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
        return operacao + " " + codigoTurma + " " + latitude + " " + longitude;
    }
}


