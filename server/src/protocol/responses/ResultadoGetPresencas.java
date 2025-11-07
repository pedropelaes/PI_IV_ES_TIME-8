package src.protocol.responses;

import java.util.List;

public class ResultadoGetPresencas extends ResultadoOperacao {
    private List<String> alunos;

    public ResultadoGetPresencas(boolean resultado, String operacao, List<String> alunos) {
        super(resultado, operacao);
        this.alunos = alunos;
    }

    public List<String> getAlunos() {
        return alunos;
    }

    public void setAlunos(List<String> alunos) {
        this.alunos = alunos;
    }
}

