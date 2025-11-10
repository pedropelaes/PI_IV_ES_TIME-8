package src.domain;

public class AlunoSimples {
    private String nome;
    private String email;

    public AlunoSimples(String nome, String email) {
        this.nome = nome;
        this.email = email;
    }

    public String getNome() {
        return nome;
    }
    public String getEmail() {
        return email;
    }

    @Override
    public String toString() {return "AlunoSimples{" + "nome=" + nome + ", email=" + email + '}';}

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        AlunoSimples a = (AlunoSimples) obj;
        if (!nome.equals(a.nome) || !email.equals(a.email)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 31 * ret + nome.hashCode();
        ret = 31 * ret + email.hashCode();
        return ret;
    }

}
