package src.domain;

import java.util.Date;
import java.util.List;

public class Turma {
    private String _id;
    private String nome;
    private String descricao;
    private String codigo;
    private String professor;
    private List<String> alunos;
    private Date criadoEm;
    private Date atualizadaEm;
    private LocPadrao localizacaoPadrao;

    public Turma() {}
    public Turma(String _id, String nome, String descricao, String codigo,
                 String professor, List<String> alunos, Date criadoEm,
                 Date atualizadaEm, LocPadrao localizacaoPadrao) {
        this._id = _id;
        this.nome = nome;
        this.descricao = descricao;
        this.codigo = codigo;
        this.professor = professor;
        this.alunos = alunos;
        this.criadoEm = criadoEm;
        this.atualizadaEm = atualizadaEm;
        this.localizacaoPadrao = localizacaoPadrao;
    }

    @Override
    public String toString() {
        return "Turma{" + "_id=" + _id + ", nome=" + nome +
                descricao + ", codigo=" + codigo + ", professor=" +
                professor  +  alunos  +  localizacaoPadrao +
                "Criado em: " + criadoEm + "Atualizado em: " + atualizadaEm + '}';
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Turma t = (Turma) obj;
        if (!this._id.equals(t._id)) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 31 + this._id.hashCode();
        ret = ret * 31 + this.nome.hashCode();
        ret = ret * 31 + this.descricao.hashCode();
        ret = ret * 31 + this.codigo.hashCode();
        ret = ret * 31 + this.professor.hashCode();
        ret = ret * 31 + this.alunos.hashCode();
        ret = ret * 31 + this.localizacaoPadrao.hashCode();
        ret = ret * 31 + this.criadoEm.hashCode();
        ret = ret * 31 + this.atualizadaEm.hashCode();

        if(ret<0) ret = -ret;
        return ret;
    }

}
