package src.domain;

public class User {
    private String _id;
    private String uid;
    private String nome;
    private String email;
    private String tipo;
    private String codigo;

    public User(){}

    public User(String _id,String uid, String nome, String email, String tipo, String codigo) {
        this._id = _id;
        this.uid = uid;
        this.nome = nome;
        this.email = email;
        this.tipo = tipo;
        this.codigo = codigo;
    }

    public String getUid() { return uid; }
    public String getEmail() { return email; }
    public String getNome() { return nome; }
    public String getTipo() { return tipo; }
    public String getCodigo() { return codigo; }

    @Override
    public String toString() {
        return "src.domain.User{" +
                "uid='" + uid + '\'' +
                ", email='" + email + '\'' +
                ", nome='" + nome + '\'' +
                ", tipo='" + tipo + '\'' +
                ", codigo='" + codigo + '\'' +
                '}';
    }
}
