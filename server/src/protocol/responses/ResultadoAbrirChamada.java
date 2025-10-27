package src.protocol.responses;


public class ResultadoAbrirChamada extends ResultadoOperacao {
    private String codigoChamada;

    public ResultadoAbrirChamada(boolean resultado, String operacao,  String codigoChamada) {
        super(resultado, operacao);
        this.codigoChamada = codigoChamada;
    }
}
