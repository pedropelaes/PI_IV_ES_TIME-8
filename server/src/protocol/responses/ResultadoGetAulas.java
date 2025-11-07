package src.protocol.responses;

import src.domain.Aula;

import java.util.List;

public class ResultadoGetAulas extends ResultadoOperacao{
    private List<Aula> aulas;

    public ResultadoGetAulas(boolean resultado, String operacao, List<Aula> aulas) {
        super(resultado, operacao);
        this.aulas = aulas;
    }
}
