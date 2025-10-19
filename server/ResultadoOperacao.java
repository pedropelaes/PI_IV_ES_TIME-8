public class ResultadoOperacao extends Comunicado {
    private boolean resultado;
    private String operacao;

    public ResultadoOperacao() {}

    public ResultadoOperacao (boolean resultado, String operacao)
    {
        this.resultado = resultado;
        this.operacao = operacao;
    }

    public boolean getResultadoOperacao(){
        return resultado;
    }

    public String getOperacao(){
        return operacao;
    }

    public String toString ()
    {
        return "{ Operacao: "+this.operacao + "Resultado: " +this.resultado +" }";
    }

}
