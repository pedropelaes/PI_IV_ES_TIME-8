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
        this.porcentagemPresenca = 1.0;
    }

    public RelatorioMensalAluno(RelatorioMensalAluno mod)throws Exception{
        if(mod == null) throw new Exception("Modelo ausente");

        this.alunoId = mod.alunoId;
        this.alunoNome = mod.alunoNome;
        this.totalDeFaltas = mod.totalDeFaltas;
        this.totalDeAulas = mod.totalDeAulas;
        this.porcentagemPresenca = mod.porcentagemPresenca;
    }

    public String getAlunoId() { return this.alunoId; }
    public String getAlunoNome() { return this.alunoNome; }
    public int getTotalDeFaltas(){return this.totalDeFaltas;}
    public int getTotalDeAulas() { return this.totalDeAulas; }
    public double getPorcentagemPresenca() { return this.porcentagemPresenca; }

    public void setAlunoId(String alunoId) {
        this.alunoId = alunoId;
    }

    public void setAlunoNome(String alunoNome) {
        this.alunoNome = alunoNome;
    }

    public void setTotalDeFaltas(int totalDeFaltas){
        this.totalDeFaltas = totalDeFaltas;
        if(this.totalDeAulas > 0){
            int presencas = this.totalDeAulas - totalDeFaltas;
            this.porcentagemPresenca = ((double) presencas / this.totalDeAulas);
        }else{
            this.porcentagemPresenca = 1.0;
        }
    }

    public void setTotalDeAulas(int totalDeAulas){
        this.totalDeAulas = totalDeAulas;
        if(this.totalDeAulas > 0){
            int presencas = this.totalDeAulas - this.totalDeFaltas;
            this.porcentagemPresenca = ((double) presencas / this.totalDeAulas);
        }else{
            this.porcentagemPresenca = 1.0;
        }
    }

    @Override
    public String toString() {
        return "alunoId: " + this.alunoId +
                "\n alunoNome: " + this.alunoNome +
                "\n totalDeFaltas: " + this.totalDeFaltas +
                "\n totalDeAulas: " + this.totalDeAulas +
                "\n porcentagemPresenca: " + this.porcentagemPresenca;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        RelatorioMensalAluno r = (RelatorioMensalAluno) obj;

        if (!this.alunoId.equals(r.alunoId)) return false;
        if (!this.alunoNome.equals(r.alunoNome)) return false;
        if (this.totalDeFaltas != r.totalDeFaltas) return false;
        if (this.totalDeAulas != r.totalDeAulas) return false;

        if (Double.compare(this.porcentagemPresenca, r.porcentagemPresenca) != 0) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 31 * ret + this.alunoId.hashCode();
        ret = 31 * ret + this.alunoNome.hashCode();
        ret = 31 * ret + Integer.hashCode(this.totalDeFaltas);
        ret = 31 * ret + Integer.hashCode(this.totalDeAulas);
        ret = 31 * ret + Double.hashCode(this.porcentagemPresenca);
        return ret;
    }
}