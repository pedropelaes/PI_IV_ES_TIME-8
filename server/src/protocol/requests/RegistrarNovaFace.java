package src.protocol.requests;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.FindOneAndUpdateOptions;
import com.mongodb.client.model.ReturnDocument;
import io.github.cdimascio.dotenv.Dotenv;
import org.bson.Document;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;

public class RegistrarNovaFace {
    private String imagem;
    private String uid;

    private static final Dotenv dotenv = Dotenv.load();
    private static final String API_KEY = dotenv.get("FACE_API_KEY");
    private static final String API_SECRET = dotenv.get("FACE_API_SECRET");
    private static final String FACESET_TOKEN = dotenv.get("FACESET_TOKEN");

    public RegistrarNovaFace(String imagem, String uid) {
        this.imagem = imagem;
        this.uid = uid;
    }

    public boolean registrar() {
        String uri = dotenv.get("MONGO_URI");


        try (MongoClient client = MongoClients.create(uri)) {
            // decodifica a imagem
            byte[] imageBytes = Base64.getDecoder().decode(imagem);
            File tempFile = File.createTempFile("face_upload", ".jpg");
            try (FileOutputStream fos = new FileOutputStream(tempFile)) {
                fos.write(imageBytes);
            }

            // detecta rosto
            String faceToken = detectarRosto(tempFile);
            tempFile.delete();

            if (faceToken == null)
                return false;

            // adiciona rosto ao FaceSet
            boolean adicionado = adicionarAoFaceSet(faceToken);
            if (!adicionado)
                return false;

            MongoDatabase db = client.getDatabase("vocattio_db");
            MongoCollection<Document> users = db.getCollection("users");
            Document filter = new Document("uid", this.uid);

            Document update = new Document("$set", new Document("faceToken", faceToken));

            FindOneAndUpdateOptions options = new FindOneAndUpdateOptions()
                    .returnDocument(ReturnDocument.AFTER);

            Document updatedUser = users.findOneAndUpdate(filter, update, options);

            if (updatedUser == null) {
                System.err.println("Usuário com uid " + this.uid + " não encontrado no banco de dados.");
                return false;
            }

            System.out.println("FaceToken " + faceToken + " salvo para o usuário " + this.uid);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private static String detectarRosto(File imageFile) throws IOException {
        String boundary = "----WebKitFormBoundary";
        String urlStr = "https://api-us.faceplusplus.com/facepp/v3/detect";
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setDoOutput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

        try (DataOutputStream out = new DataOutputStream(conn.getOutputStream())) {
            out.writeBytes("--" + boundary + "\r\n");
            out.writeBytes("Content-Disposition: form-data; name=\"api_key\"\r\n\r\n" + API_KEY + "\r\n");
            out.writeBytes("--" + boundary + "\r\n");
            out.writeBytes("Content-Disposition: form-data; name=\"api_secret\"\r\n\r\n" + API_SECRET + "\r\n");
            out.writeBytes("--" + boundary + "\r\n");
            out.writeBytes("Content-Disposition: form-data; name=\"image_file\"; filename=\"upload.jpg\"\r\n");
            out.writeBytes("Content-Type: image/jpeg\r\n\r\n");
            out.write(imageFileToBytes(imageFile));
            out.writeBytes("\r\n--" + boundary + "--\r\n");
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) response.append(line);
        reader.close();

        JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
        if (json.has("faces") && json.getAsJsonArray("faces").size() > 0) {
            return json.getAsJsonArray("faces").get(0).getAsJsonObject().get("face_token").getAsString();
        }
        return null;
    }

    private static byte[] imageFileToBytes(File file) throws IOException {
        return java.nio.file.Files.readAllBytes(file.toPath());
    }

    private static boolean adicionarAoFaceSet(String faceToken) throws IOException {
        String urlStr = "https://api-us.faceplusplus.com/facepp/v3/faceset/addface";
        URL url = new URL(urlStr);
        String postData = "api_key=" + API_KEY +
                "&api_secret=" + API_SECRET +
                "&faceset_token=" + FACESET_TOKEN +
                "&face_tokens=" + faceToken;

        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setDoOutput(true);
        conn.setRequestMethod("POST");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(postData.getBytes());
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) response.append(line);
        reader.close();

        JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
        return json.has("face_added") && json.get("face_added").getAsInt() > 0;
    }

    @Override
    public String toString() {
        return "Foto para usuario:" + this.uid;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) return true;
        if (obj == null || obj.getClass() != this.getClass()) return false;
        RegistrarNovaFace r = (RegistrarNovaFace) obj;
        return this.imagem.equals(r.imagem) && this.uid.equals(r.uid);
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 31 + this.imagem.hashCode();
        ret = ret * 31 + this.uid.hashCode();
        if(ret<0) ret=-ret;
        return ret;
    }
}
