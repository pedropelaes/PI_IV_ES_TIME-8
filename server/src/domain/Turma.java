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



}
