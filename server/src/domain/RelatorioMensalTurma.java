package src.domain;

import java.util.ArrayList;
import java.util.List;

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
        this.mediaDaTurma = 100.0;
    }

    public void setTotalDeFaltas(int totalDeFaltas){
        this.totalDeFaltas = totalDeFaltas;
        if(this.totalDeAulas > 0){
            int presencas = this.totalDeAulas - totalDeFaltas;
            this.mediaDaTurma = ((double) presencas / this.totalDeAulas);
        }else{
            this.mediaDaTurma = 100.0;
        }
    }

    public List<FaltasDoDia> getDiasInfo(){ return this.diasInfo; }
    public List<RelatorioMensalAluno> getAlunosInfo(){ return this.alunosInfo; }
    public int getTotalDeFaltas(){ return this.totalDeFaltas; }
    public int getTotalDeAulas() { return this.totalDeAulas; }
    public double getMediaDaTurma(){ return this.mediaDaTurma; }

    public RelatorioMensalTurma(RelatorioMensalTurma mod)throws Exception{
        if(mod == null) throw new Exception("Modelo ausente");

        this.totalDeFaltas = mod.totalDeFaltas;
        this.totalDeAulas = mod.totalDeAulas;
        this.mediaDaTurma = mod.mediaDaTurma;

        this.alunosInfo = new ArrayList<>();
        for (RelatorioMensalAluno aluno : mod.alunosInfo) {
            this.alunosInfo.add(new RelatorioMensalAluno(aluno)); // exige construtor de cópia no aluno
        }

        this.diasInfo = new ArrayList<>();
        for (FaltasDoDia dia : mod.diasInfo) {
            this.diasInfo.add(new FaltasDoDia(dia)); // exige construtor de cópia no FaltasDoDia
        }
    }
}
