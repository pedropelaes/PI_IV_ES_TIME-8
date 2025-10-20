public class Turma {
    private String nome;
    private String codigo;
    private String professorId;
    private String[] alunos;
    private String criadoEm;
    private String atualizadoEm;

    public Turma(String nome, String codigo, String professorId, String[] alunos, String criadoEm, String atualizadoEm) {
        this.nome = nome;
        this.codigo = codigo;
        this.professorId = professorId;
        this.alunos = alunos;
        this.criadoEm = criadoEm;
        this.atualizadoEm = atualizadoEm;
    }

    @Override
    public String toString() {
        return "Turma{" +
                "nome='" + nome + '\'' +
                ", codigo='" + codigo + '\'' +
                ", professorId='" + professorId + '\'' +
                ", alunos=" + java.util.Arrays.toString(alunos) +
                ", criadoEm='" + criadoEm + '\'' +
                ", atualizadoEm='" + atualizadoEm + '\'' +
                '}';
    }
}
