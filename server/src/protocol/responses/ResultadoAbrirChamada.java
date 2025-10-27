package src.protocol.responses;


import com.google.gson.Gson;

public class ResultadoAbrirChamada extends ResultadoOperacao {
    private String codigoChamada;

    public ResultadoAbrirChamada(boolean resultado, String operacao,  String codigoChamada) {
        super(resultado, operacao);
        this.codigoChamada = codigoChamada;
    }

    public String getResultado() {
        Gson gson = new Gson();
        return gson.toJson(this);
    }
}
