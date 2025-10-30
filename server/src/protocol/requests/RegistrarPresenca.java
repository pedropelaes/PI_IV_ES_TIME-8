package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;
import org.bson.types.ObjectId;

public class RegistrarPresenca {
    private String aulaId;
    private String alunoId;
    private Double latitude;   // latitude do aluno
    private Double longitude;  // longitude do aluno

    public RegistrarPresenca() {}

    public boolean registrarPresenca() {
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient mongoClient = MongoClients.create(uri)) {
            // Usa o mesmo banco de dados de AbrirChamada
            MongoDatabase database = mongoClient.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = database.getCollection("aulas");

            if (aulaId == null || alunoId == null || latitude == null || longitude == null) {
                System.out.println("Parâmetros insuficientes para registrar presença");
                return false;
            }

            // Busca a aula para obter a localização do professor
            Document aula = aulas.find(Filters.eq("_id", new ObjectId(aulaId))).first();
            if (aula == null) {
                System.out.println("Aula não encontrada para o id: " + aulaId);
                return false;
            }

            Double latProfessor = aula.getDouble("latitude");
            Double lonProfessor = aula.getDouble("longitude");
            if (latProfessor == null || lonProfessor == null) {
                System.out.println("Aula sem latitude/longitude do professor");
                return false;
            }

            double distancia = haversineMeters(latProfessor, lonProfessor, latitude, longitude);
            System.out.println("Distância aluno-professor: " + distancia + "m");
            if (distancia > 100.0) {
                System.out.println("Aluno fora do raio permitido (100m)");
                return false;
            }

            // Adiciona o ID do aluno no array "presentes" (sem duplicar)
            aulas.updateOne(
                    Filters.eq("_id", new ObjectId(aulaId)),
                    Updates.addToSet("presentes", new ObjectId(alunoId))
            );

            return true;
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
}
