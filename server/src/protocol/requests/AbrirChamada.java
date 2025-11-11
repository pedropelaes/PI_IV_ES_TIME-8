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

import dev.samstevens.totp.secret.DefaultSecretGenerator;
import dev.samstevens.totp.secret.SecretGenerator;

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
            MongoCollection<Document> users = db.getCollection("users");

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

            // caso os valores de longitude e latitude cheguem zerados, faz fallback com a localizacao da turma
            if(this.latitude == 0 && this.longitude == 0){
                Document cordturma = turma.get("localizacaoPadrao", Document.class);
                if(cordturma != null){
                    setLatitude(cordturma.getDouble("latitude"));
                    setLongitude(cordturma.getDouble("longitude"));
                }
            }

            ArrayList<ObjectId> alunosIds = turma.get("alunos", ArrayList.class);

            // 3. [NOVO] Cria a lista de presença (o "snapshot")
            ArrayList<Document> listaPresenca = new ArrayList<>();
            if (alunosIds != null) {
                for (ObjectId alunoId : alunosIds) {
                    Document aluno = users.find(Filters.eq("_id", alunoId))
                                        .projection(new Document("nome", 1))
                                        .first();
                    String nomeAluno = (aluno != null) ? aluno.getString("nome") : "";

                    listaPresenca.add(new Document("alunoId", alunoId)
                                    .append("nome", nomeAluno)
                            .append("presente", false)
                    );
                }
            }

            // Gera um código único para a chamada
            String codigoChamada = "CHAMADA-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();

            // Gera chave secreta para os codigos temporários
            SecretGenerator secretGenerator = new DefaultSecretGenerator(64);
            String chaveTOTP = secretGenerator.generate();

            // Cria o documento de aula
            Document aula = new Document()
                    .append("turmaId", new ObjectId(codigoTurma))
                    .append("codigo", codigoChamada)
                    .append("chaveTOTP", chaveTOTP)
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

    public void setLatitude(double lat){
        this.latitude = lat;
    }
    public void setLongitude(double lon){
        this.longitude = lon;
    }

    @Override
    public String toString() {
        return operacao + " " + codigoTurma + " " + latitude + " " + longitude;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (obj == null || getClass() != obj.getClass()) return false;
        AbrirChamada a = (AbrirChamada) obj;
        if (!this.codigoTurma.equals(a.codigoTurma) || this.latitude != a.latitude || this.longitude != a.longitude
                || this.operacao.equals(a.operacao)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 31 * ret + this.codigoTurma.hashCode();
        ret = 2 * ret + ((Double)this.latitude).hashCode();
        ret = 31 * ret + ((Double)this.longitude).hashCode();
        ret = 31 * ret + this.operacao.hashCode();
        return ret;
    }

}


