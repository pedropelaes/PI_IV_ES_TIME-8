package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import com.mongodb.client.result.UpdateResult;
import dev.samstevens.totp.code.*;
import dev.samstevens.totp.time.SystemTimeProvider;
import dev.samstevens.totp.time.TimeProvider;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;

public class RegistrarPresenca {
    private String aulaId;
    private String alunoId;
    private Double latitude;   // latitude do aluno
    private Double longitude;  // longitude do aluno
    private String codigoChamada; // código textual da chamada (QR)
    private String codigoTemporario;
    private String mensagem;

    public RegistrarPresenca() {}

    public boolean registrarPresenca() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient mongoClient = MongoClients.create(uri)) {
            // Usa o mesmo banco de dados de AbrirChamada
            MongoDatabase database = mongoClient.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = database.getCollection("aulas");

            if (alunoId == null || latitude == null || longitude == null) {
                this.mensagem = "Parâmetros insuficientes para registrar presença";
                System.out.println(this.mensagem);
                return false;
            }

            // Busca a aula: por codigoChamada (preferencial) ou por _id
            Document aula = null;
            if (codigoChamada != null && !codigoChamada.isEmpty()) {
                aula = aulas.find(Filters.eq("codigo", codigoChamada)).first();
            } else if (aulaId != null && !aulaId.isEmpty()) {
                aula = aulas.find(Filters.eq("_id", new ObjectId(aulaId))).first();
            }
            if (aula == null) {
                this.mensagem = "Aula não encontrada";
                System.out.println(this.mensagem);
                return false;
            }

            Double latProfessor = aula.getDouble("latitude");
            Double lonProfessor = aula.getDouble("longitude");
            if (latProfessor == null || lonProfessor == null) {
                this.mensagem = "Aula sem latitude/longitude do professor";
                System.out.println(this.mensagem);
                return false;
            }

            String chaveTOTP = aula.getString("chaveSecretaTOTP");
            if(chaveTOTP == null || this.codigoTemporario == null){
                return false;
            }

            TimeProvider timeProvider = new SystemTimeProvider();
            CodeGenerator codeGenerator = new DefaultCodeGenerator(HashingAlgorithm.SHA1, 6);
            DefaultCodeVerifier verifier = new DefaultCodeVerifier(codeGenerator, timeProvider);
            verifier.setTimePeriod(15);
            verifier.setAllowedTimePeriodDiscrepancy(1);

            if(!verifier.isValidCode(chaveTOTP, this.codigoTemporario)){ // verificação de codigo temporario
                return false;
            }

            double distancia = haversineMeters(latProfessor, lonProfessor, latitude, longitude);
            System.out.println("Distância aluno-professor: " + distancia + "m");
            if (distancia > 80.0) {
                this.mensagem = "Fora do raio permitido (100m)";
                System.out.println(this.mensagem);
                return false;
            }

            ObjectId aulaObjectId = aula.getObjectId("_id");
            ObjectId alunoObjectId;
            try {
                alunoObjectId = new ObjectId(this.alunoId);
            } catch (IllegalArgumentException e) {
                this.mensagem = "ID de aluno inválido";
                System.out.println(this.mensagem);
                return false;
            };

            UpdateResult updateResult = aulas.updateOne(
                    Filters.and(
                            Filters.eq("_id", aulaObjectId), // Filtra a aula correta
                            Filters.eq("presentes.alunoId", alunoObjectId), // Encontra o aluno no array
                            Filters.eq("presentes.presente", false) // SÓ atualiza se ele ainda não marcou
                    ),
                    Updates.combine(
                            Updates.set("presentes.$.presente", true)
                    )
            );

            if (updateResult.getModifiedCount() > 0) {
                this.mensagem = "Presença registrada com sucesso!";
                System.out.println(this.mensagem);
                return true;
            } else {
                Document alunoPresenteCheck = aulas.find(
                        Filters.and(
                                Filters.eq("_id", aulaObjectId),
                                Filters.eq("presentes.alunoId", alunoObjectId),
                                Filters.eq("presentes.presente", true)
                        )
                ).projection(new Document("_id", 1)).first();

                if (alunoPresenteCheck != null) {
                    this.mensagem = "Aluno já estava com presença registrada.";
                    System.out.println(this.mensagem);
                    return true;
                } else {
                    this.mensagem = "Aluno não encontrado na lista de chamada desta aula.";
                    System.out.println(this.mensagem);
                    return false;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Calcula a distância entre dois pontos em metros (fórmula de Haversine)
    private static double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371000.0; // raio médio da Terra em metros
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    // getters/setters usados pelo Gson
    public String getAulaId() { return aulaId; }
    public void setAulaId(String aulaId) { this.aulaId = aulaId; }
    public String getAlunoId() { return alunoId; }
    public void setAlunoId(String alunoId) { this.alunoId = alunoId; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public String getCodigoChamada() { return codigoChamada; }
    public void setCodigoChamada(String codigoChamada) { this.codigoChamada = codigoChamada; }
    public String getMensagem() { return mensagem; }

    @Override
    public String toString() {return "" + this.aulaId + this.alunoId + this.codigoChamada + this.mensagem + this.latitude +  this.longitude;}

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 31 + this.aulaId.hashCode();
        ret = ret * 31 + this.alunoId.hashCode();
        ret = ret * 31 + this.codigoChamada.hashCode();
        ret = ret * 31 + this.mensagem.hashCode();
        ret = ret * 31 + this.latitude.hashCode();
        ret = ret * 31 + this.longitude.hashCode();
        return ret;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        RegistrarPresenca r = (RegistrarPresenca) obj;
        if (!this.aulaId.equals(r.aulaId) || !this.alunoId.equals(r.alunoId) || !this.codigoChamada.equals(r.codigoChamada)||
                !this.mensagem.equals(r.mensagem) || !this.latitude.equals(r.latitude)
                || !this.longitude.equals(r.longitude)) return false;
        return true;
    }

}
