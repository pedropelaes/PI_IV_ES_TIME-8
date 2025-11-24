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

    public void setDiaDaSemana(String diaDaSemana) {
        this.diaDaSemana = diaDaSemana;
    }

    public void setTotalDeFaltas(int totalDeFaltas) {
        this.totalDeFaltas = totalDeFaltas;
    }

    public FaltasDoDia(FaltasDoDia mod)throws Exception{
        if(mod == null) throw new Exception("Modelo ausente");

        this.diaDaSemana = mod.diaDaSemana;
        this.totalDeFaltas = mod.totalDeFaltas;
    }

    @Override
    public String toString() {
        return "diaDaSemana: " + this.diaDaSemana +
                "\n totalDeFaltas: " + this.totalDeFaltas;
    }

    @Override
    public boolean equals(Object obj){
        if(obj == this) return true;
        if(obj == null) return false;
        if(this.getClass() != obj.getClass()) return false;
        FaltasDoDia f = (FaltasDoDia) obj;

        if (!this.diaDaSemana.equals(f.diaDaSemana)) return false;
        if (this.totalDeFaltas != f.totalDeFaltas) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = 31 * ret + this.diaDaSemana.hashCode();
        ret = 31 * ret + Integer.hashCode(this.totalDeFaltas);
        return ret;
    }
}