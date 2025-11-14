package src.domain;

import java.util.Date;

public class FaltasDoDia {
    private Date data;
    private int totalDeFaltas;

    public FaltasDoDia(Date data, int totalFaltas) {
        this.data = data;
        this.totalDeFaltas = totalFaltas;
    }

    public Date getData() {
        return data;
    }

    public int getTotalFaltas() {
        return totalDeFaltas;
    }

    public FaltasDoDia(FaltasDoDia mod)throws Exception{
        if(mod == null) throw new Exception("Modelo ausente");

        this.data = mod.data != null ? new Date(mod.data.getTime()) : null;
        this.totalDeFaltas = mod.totalDeFaltas;
    }
}
