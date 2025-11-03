package src.domain;

public class Presenca {
    private String alunoId;
    private boolean presente;

    public Presenca(){}

    public Presenca(String alunoId, boolean presente) {
        this.alunoId = alunoId;
        this.presente = presente;
    }

    public String getAlunoId() {
        return alunoId;
    }
    public boolean getPresente() {
        return presente;
    }
}
