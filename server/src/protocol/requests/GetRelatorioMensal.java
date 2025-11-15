package src.protocol.requests;

import src.domain.*;

import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class GetRelatorioMensal {
    private String turmaId;
    private int mes;
    private int ano;

    public GetRelatorioMensal(String turmaId, int mes, int ano){
        this.turmaId = turmaId;
        this.mes = mes;
        this.ano = ano;
    }

    public RelatorioMensalTurma gerarRelatorio(){
        if(this.turmaId == null || this.mes < 1 || this.mes > 12 ){
            return null;
        }

        GetAulas getAulas = new GetAulas(this.turmaId);
        List<Aula> aulas = getAulas.getAulasFromTurma();

        if(aulas == null) return null;
        List<Aula> aulasDoMes = aulas.stream()
                .filter(aula -> aula.getDataAbertura() != null)
                .filter(aula -> {
                    var cal = java.util.Calendar.getInstance();
                    cal.setTime(aula.getDataAbertura());
                    int mesAula = cal.get(Calendar.MONTH) + 1;
                    int anoAula = cal.get(Calendar.YEAR);
                    return mesAula == this.mes && anoAula == this.ano;
                })
                .toList();

        RelatorioMensalTurma relatorio = new RelatorioMensalTurma(aulasDoMes.size());
        if(aulasDoMes.isEmpty()){
            return relatorio;
        }

        Map<String, RelatorioMensalAluno> alunosMap = new HashMap<>();

        for (Aula aula : aulasDoMes) {
            for (Presenca p : aula.getPresentes()) {
                alunosMap.putIfAbsent(
                        p.getAlunoId(),
                        new RelatorioMensalAluno(
                                p.getAlunoId(),
                                p.getNome(),
                                aulasDoMes.size()
                        )
                );
            }
        }

        int faltasTotais = 0;

        Map<Integer, Integer> faltasPorDiaDaSemana = new HashMap<>();
        Calendar cal = Calendar.getInstance();

        for(Aula aula : aulasDoMes){
            int faltasDoDia = 0;
            for(Presenca p : aula.getPresentes()){
                if(!p.getPresente()){
                    faltasDoDia++;
                    RelatorioMensalAluno aluno = alunosMap.get(p.getAlunoId());
                    aluno.setTotalDeFaltas(aluno.getTotalDeFaltas() + 1);
                }
            }
            faltasTotais += faltasDoDia;

            cal.setTime(aula.getDataAbertura());
            int diaDaSemana = cal.get(Calendar.DAY_OF_WEEK);

            faltasPorDiaDaSemana.merge(diaDaSemana, faltasDoDia, Integer::sum);
        }

        for (Map.Entry<Integer, Integer> entry : faltasPorDiaDaSemana.entrySet()) {
            String nomeDia = getNomeDiaDaSemana(entry.getKey());
            int totalFaltasDia = entry.getValue();

            relatorio.getDiasInfo().add(new FaltasDoDia(nomeDia, totalFaltasDia));
        }

        relatorio.getAlunosInfo().addAll(alunosMap.values());
        relatorio.setTotalDeFaltas(faltasTotais);


        return relatorio;
    }

    private String getNomeDiaDaSemana(int calendarDayOfWeek) {
        switch (calendarDayOfWeek) {
            case Calendar.SUNDAY: return "Domingo";
            case Calendar.MONDAY: return "Segunda-feira";
            case Calendar.TUESDAY: return "Terça-feira";
            case Calendar.WEDNESDAY: return "Quarta-feira";
            case Calendar.THURSDAY: return "Quinta-feira";
            case Calendar.FRIDAY: return "Sexta-feira";
            case Calendar.SATURDAY: return "Sábado";
            default: return "Desconhecido";
        }
    }

    public String getTurmaId() { return turmaId; }
    public int getMes() { return mes; }
    public int getAno() { return ano; }

}
