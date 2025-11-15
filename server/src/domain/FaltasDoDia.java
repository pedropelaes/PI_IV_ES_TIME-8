package src.domain;


public class FaltasDoDia {
    private String diaDaSemana;
    private int totalDeFaltas;

    public FaltasDoDia(String data, int totalFaltas) {
        this.diaDaSemana = data;
        this.totalDeFaltas = totalFaltas;
    }

    public String getData() {
        return diaDaSemana;
    }

    public int getTotalFaltas() {
        return totalDeFaltas;
    }

    public FaltasDoDia(FaltasDoDia mod)throws Exception{
        if(mod == null) throw new Exception("Modelo ausente");

        this.diaDaSemana = mod.diaDaSemana;
        this.totalDeFaltas = mod.totalDeFaltas;
    }
}
