package src.protocol.responses;

public class ResultadoGetCodigoTemporario extends ResultadoOperacao{
    private String codigoTemporario;

    public ResultadoGetCodigoTemporario(boolean resultado, String operacao, String codigoTemporario){
        super(resultado, operacao);
        this.codigoTemporario = codigoTemporario;
    }

    public String getCodigoTemporario(){
        return this.codigoTemporario;
    }
}
