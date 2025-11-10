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

    @Override
    public String toString() {return "AlunoID: " + this.alunoId + ", Nome: " + this.nome + ", Presente: " + this.presente;}

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 31 + this.alunoId.hashCode();
        ret = ret * 31 + this.nome.hashCode();
        ret = ret * 31 + (this.presente ? 1 : 0);
        return ret;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        Presenca p = (Presenca) obj;
        if (!this.alunoId.equals(p.alunoId) || !this.nome.equals(p.nome) || this.presente != p.presente) return false;
        return true;
    }

}
