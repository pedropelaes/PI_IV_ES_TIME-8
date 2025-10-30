package src.protocol.requests;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;

import java.time.Instant;

public class FecharChamada {
    private String codigoChamada;
    private String operacao;

    public FecharChamada() {}

    public boolean fechar() {
        System.out.println("Método fechar() chamado. codigoChamada: " + codigoChamada);
        
        Dotenv dotenv = Dotenv.load();
        String uri = dotenv.get("MONGO_URI");

        try (MongoClient client = MongoClients.create(uri)) {
            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> aulas = db.getCollection("aulas");

            if (codigoChamada == null || codigoChamada.isEmpty()) {
                System.out.println("Erro: codigoChamada está null ou vazio!");
                return false;
            }

            System.out.println("Buscando chamada com código: " + codigoChamada);
            
            // Busca a aula pelo código e a fecha
            Document aulaAtualizada = aulas.findOneAndUpdate(
                Filters.eq("codigo", codigoChamada),
                Updates.combine(
                    Updates.set("aberta", false),
                    Updates.set("dataFechamento", Instant.now().toString())
                )
            );

            if (aulaAtualizada == null) {
                System.out.println("Chamada não encontrada: " + codigoChamada);
                return false;
            }

            System.out.println("Chamada fechada com sucesso: " + codigoChamada);
            System.out.println("Documento antes do fechamento: " + aulaAtualizada.toJson());
            
            // Verifica se foi atualizado
            Document aulaVerificada = aulas.find(Filters.eq("codigo", codigoChamada)).first();
            if (aulaVerificada != null) {
                System.out.println("Documento após fechamento: " + aulaVerificada.toJson());
            }
            
            return true;
        } catch (Exception e) {
            System.out.println("Exceção ao fechar chamada: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Getters e setters para Gson
    public String getCodigoChamada() { return codigoChamada; }
    public void setCodigoChamada(String codigoChamada) { this.codigoChamada = codigoChamada; }
    public String getOperacao() { return operacao; }
    public void setOperacao(String operacao) { this.operacao = operacao; }
}

