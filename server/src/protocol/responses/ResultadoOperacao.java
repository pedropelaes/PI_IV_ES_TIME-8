package src.protocol.responses;

import src.protocol.Comunicado;

public class ResultadoOperacao extends Comunicado {
    private boolean resultado;
    private String operacao;
    private String mensagem;

    public ResultadoOperacao() {}

    public ResultadoOperacao (boolean resultado, String operacao)
    {
        this.resultado = resultado;
        this.operacao = operacao;
        this.mensagem = null;
    }

    public ResultadoOperacao (boolean resultado, String operacao, String mensagem)
    {
        this.resultado = resultado;
        this.operacao = operacao;
        this.mensagem = mensagem;
    }

    // Getters usados pelo Gson para serialização
    public boolean getResultado(){
        return resultado;
    }
    
    public boolean getResultadoOperacao(){
        return resultado;
    }

    public String getOperacao(){
        return operacao;
    }

    public String getMensagem() { return mensagem; }

    public String toString ()
    {
        return "{ Operacao: "+this.operacao + " Resultado: " +this.resultado + (this.mensagem != null ? (" Mensagem: "+this.mensagem) : "") +" }";
    }

}
