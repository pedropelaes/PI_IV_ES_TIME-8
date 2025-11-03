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
}
