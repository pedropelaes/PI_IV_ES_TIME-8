package src.protocol.responses;

import src.domain.Turma;

import java.util.List;

public class ResultadoGetTurmas extends ResultadoOperacao{
    private List<Turma> turmas;

    public ResultadoGetTurmas(boolean resultado, String operacao, List<Turma> turmas) {
        super(resultado, operacao);
        this.turmas = turmas;
    }
}
