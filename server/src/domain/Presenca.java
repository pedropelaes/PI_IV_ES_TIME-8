package src.domain;

public class Presenca {
    private String alunoId;
    private String nome;
    private boolean presente;

    public Presenca(){}

    public Presenca(String alunoId, String nome, boolean presente) {
        this.alunoId = alunoId;
        this.nome = nome;
        this.presente = presente;
    }

    public String getAlunoId() {
        return alunoId;
    }
    public String getNome() {
        return nome;
    }
    public boolean getPresente() {
        return presente;
    }
}
