package src.domain;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class RelatorioMensalTurma {
    private List<RelatorioMensalAluno> alunosInfo;
    private List<FaltasDoDia> diasInfo;
    private int totalDeFaltas;
    private int totalDeAulas;
    private double mediaDaTurma;

    public RelatorioMensalTurma(int totalDeAulas){
        this.alunosInfo = new ArrayList<RelatorioMensalAluno>();
        this.diasInfo = new ArrayList<FaltasDoDia>(5);
        this.totalDeAulas = totalDeAulas;
        this.totalDeFaltas = 0;
        this.mediaDaTurma = 1.0;
    }

    public RelatorioMensalTurma(RelatorioMensalTurma mod)throws Exception{
        if(mod == null) throw new Exception("Modelo ausente");

        this.totalDeFaltas = mod.totalDeFaltas;
        this.totalDeAulas = mod.totalDeAulas;
        this.mediaDaTurma = mod.mediaDaTurma;

        this.alunosInfo = new ArrayList<>();
        for (RelatorioMensalAluno aluno : mod.alunosInfo) {
            this.alunosInfo.add(new RelatorioMensalAluno(aluno));
        }

        this.diasInfo = new ArrayList<>();
        for (FaltasDoDia dia : mod.diasInfo) {
            this.diasInfo.add(new FaltasDoDia(dia));
        }
    }

    private void calcularMediaDaTurma() {
        int numeroDeAlunos = this.alunosInfo.size();

        if(this.totalDeAulas > 0 && numeroDeAlunos > 0){
            int totalPresencasPossiveis = this.totalDeAulas * numeroDeAlunos;
            int presencasReais = totalPresencasPossiveis - this.totalDeFaltas;
            this.mediaDaTurma = ((double) presencasReais / totalPresencasPossiveis);
        } else if (this.totalDeAulas == 0) {
            this.mediaDaTurma = 1.0;
        } else {
            this.mediaDaTurma = 0.0;
        }
    }

    public List<FaltasDoDia> getDiasInfo(){ return this.diasInfo; }
    public List<RelatorioMensalAluno> getAlunosInfo(){ return this.alunosInfo; }
    public int getTotalDeFaltas(){ return this.totalDeFaltas; }
    public int getTotalDeAulas() { return this.totalDeAulas; }
    public double getMediaDaTurma(){ return this.mediaDaTurma; }

    public void setTotalDeFaltas(int totalDeFaltas){
        this.totalDeFaltas = totalDeFaltas;
        calcularMediaDaTurma();
    }

    public void setTotalDeAulas(int totalDeAulas){
        this.totalDeAulas = totalDeAulas;
        calcularMediaDaTurma();
    }

    public void setAlunosInfo(List<RelatorioMensalAluno> alunosInfo) {
        this.alunosInfo = alunosInfo;
        calcularMediaDaTurma();
    }

    public void setDiasInfo(List<FaltasDoDia> diasInfo) {
        this.diasInfo = diasInfo;
    }

    @Override
    public String toString() {
        return "alunosInfo: " + this.alunosInfo +
                "\n diasInfo: " + this.diasInfo +
                "\n totalDeFaltas: " + this.totalDeFaltas +
                "\n totalDeAulas: " + this.totalDeAulas +
                "\n mediaDaTurma: " + this.mediaDaTurma;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        RelatorioMensalTurma r = (RelatorioMensalTurma) obj;

        if (!this.alunosInfo.equals(r.alunosInfo)) return false;
        if (!this.diasInfo.equals(r.diasInfo)) return false;
        if (this.totalDeFaltas != r.totalDeFaltas) return false;
        if (this.totalDeAulas != r.totalDeAulas) return false;
        if (Double.compare(this.mediaDaTurma, r.mediaDaTurma) != 0) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 31 * ret + this.alunosInfo.hashCode();
        ret = 31 * ret + this.diasInfo.hashCode();
        ret = 31 * ret + Integer.hashCode(this.totalDeFaltas);
        ret = 31 * ret + Integer.hashCode(this.totalDeAulas);
        ret = 31 * ret + Double.hashCode(this.mediaDaTurma);
        return ret;
    }
}