package src.domain;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Aula {
    private String _id;
    private String turmaId;
    private String codigo;
    private boolean aberta;
    private Double latitude;
    private Double longitude;
    private Date dataAbertura;
    private List<Presenca> presentes;
    private Date dataFechamento;

    public Aula(){}
    public Aula(String _id, String turmaId, String codigo, boolean aberta, Double latitude,
                Double longitude, Date dataAbertura, List<Presenca> presentes, Date dataFechamento) {
        this._id = _id;
        this.turmaId = turmaId;
        this.codigo = codigo;
        this.aberta = aberta;
        this.latitude = latitude;
        this.longitude = longitude;
        this.dataAbertura = dataAbertura;
        this.presentes = presentes;
        this.dataFechamento = dataFechamento;
    }


}
