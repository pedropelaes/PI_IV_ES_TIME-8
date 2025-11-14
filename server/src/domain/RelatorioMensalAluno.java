package src.domain;

public class RelatorioMensalAluno {
    private String alunoId;
    private String alunoNome;
    private int totalDeFaltas;
    private int totalDeAulas;
    private double porcentagemPresenca;

    public RelatorioMensalAluno(String alunoId, String alunoNome, int totalDeAulas){
        this.alunoId = alunoId;
        this.alunoNome = alunoNome;
        this.totalDeAulas = totalDeAulas;
        this.totalDeFaltas = 0;
        this.porcentagemPresenca = 100.0;
    }

    public void setTotalDeFaltas(int totalDeFaltas){
        this.totalDeFaltas = totalDeFaltas;
        if(this.totalDeAulas > 0){
            int presencas = this.totalDeAulas - totalDeFaltas;
            this.porcentagemPresenca = ((double) presencas / this.totalDeAulas);
        }else{
            this.porcentagemPresenca = 100.0;
        }
    }

    public int getTotalDeFaltas(){return this.totalDeFaltas;}

    public RelatorioMensalAluno(RelatorioMensalAluno mod)throws Exception{
        if(mod == null) throw new Exception("Modelo ausente");

        this.alunoId = mod.alunoId;
        this.alunoNome = mod.alunoNome;
        this.totalDeFaltas = mod.totalDeFaltas;
        this.totalDeAulas = mod.totalDeAulas;
        this.porcentagemPresenca = mod.porcentagemPresenca;
    }
}
