import com.google.gson.Gson;

public class ResultadoLogin extends ResultadoOperacao{
    private User user;

    public ResultadoLogin(boolean resultado, String operacao, User user) {
        super(resultado, operacao); // inicializa os campos do pai
        this.user = user;
    }

    public String getResultado() {
        Gson gson = new Gson();
        return gson.toJson(this);
    }
}
