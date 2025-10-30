package src.protocol.responses;

public class ResultadoAbrirChamada extends ResultadoOperacao {
    private String codigoChamada;

    public ResultadoAbrirChamada(boolean resultado, String operacao,  String codigoChamada) {
        super(resultado, operacao);
        this.codigoChamada = codigoChamada;
    }

    public String getCodigoChamada() {
        return codigoChamada;
    }

    public void setCodigoChamada(String codigoChamada) {
        this.codigoChamada = codigoChamada;
    }
}
