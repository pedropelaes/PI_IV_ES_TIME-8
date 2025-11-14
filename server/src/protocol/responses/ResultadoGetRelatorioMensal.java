package src.protocol.responses;

import src.domain.RelatorioMensalAluno;
import src.domain.RelatorioMensalTurma;

public class ResultadoGetRelatorioMensal extends ResultadoOperacao{
    private RelatorioMensalTurma relatorioMensalTurma;

    public ResultadoGetRelatorioMensal(String operacao, boolean resultado, RelatorioMensalTurma relatorioMensalTurma) throws Exception {
        super(resultado, operacao);
        this.relatorioMensalTurma = new RelatorioMensalTurma(relatorioMensalTurma);
    }

}
