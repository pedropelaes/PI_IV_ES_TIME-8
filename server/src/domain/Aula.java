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

    public Date getDataAbertura(){ return this.dataAbertura; }
    public List<Presenca> getPresentes (){return this.presentes;}

    @Override
    public String toString(){
        return "_id: " + this._id +
                "\n turmaId: " + this.turmaId +
                "\n codigo: " + this.codigo +
                "\n aberta: " + this.aberta +
                "\n latitude: " + this.latitude +
                "\n longitude: " + this.longitude +
                "\n dataAbertura: " + this.dataAbertura +
                "\n presentes: " + this.presentes +
                "\n dataFechamento: " + this.dataFechamento;
    }

    @Override
    public boolean equals(Object obj){
        if(obj == this) return true;
        if(obj == null) return false;
        if(this.getClass() != obj.getClass()) return false;
        Aula a = (Aula) obj;
        return this._id != null && this._id.equals(a._id);
    }

    @Override
    public int hashCode(){
        int ret = 1;
        ret = 31 * ret + this._id.hashCode();
        ret = 31 * ret + this.turmaId.hashCode();
        ret = 31 * ret + this.codigo.hashCode();
        ret = 31 * ret + this.latitude.hashCode();
        ret = 31 * ret + this.longitude.hashCode();
        ret = 31 * ret + this.dataAbertura.hashCode();
        ret = 31 * ret + this.presentes.hashCode();
        ret = 31 * ret + this.dataFechamento.hashCode();
        ret = 31 * ret + this.presentes.hashCode();
        return ret;
    }

}
