package src.domain;

import java.util.List;

public class User {
    private String _id;
    private String uid;
    private String nome;
    private String email;
    private String tipo;
    private String codigo;
    private List<String> turmas;

    public User(){}

    public User(String _id,String uid, String nome, String email, String tipo, String codigo, List<String> turmas) {
        this._id = _id;
        this.uid = uid;
        this.nome = nome;
        this.email = email;
        this.tipo = tipo;
        this.codigo = codigo;
        this.turmas = turmas;
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

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        User u = (User) obj;
        if (!_id.equals(u._id)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 31 * ret + _id.hashCode();
        ret = 31 * ret + uid.hashCode();
        ret =  31 * ret + nome.hashCode();
        ret =  31 * ret + email.hashCode();
        ret =  31 * ret + tipo.hashCode();
        ret =  31 * ret + codigo.hashCode();
        ret =  31 * ret + turmas.hashCode();
        return ret;
    }

}
