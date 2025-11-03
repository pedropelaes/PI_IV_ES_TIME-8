package src.protocol.responses;

import src.domain.AlunoSimples;

import java.util.List;

public class ResultadoGetAlunosSimples extends ResultadoOperacao{
    private List<AlunoSimples> alunos;

    public ResultadoGetAlunosSimples(boolean resultado, String operacao, List<AlunoSimples> alunos) {
        super(resultado, operacao);
        this.alunos = alunos;
    }
}
