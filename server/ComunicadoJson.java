public class ComunicadoJson extends Comunicado
{
    private String json;

    public ComunicadoJson(String json)
    {
        this.json = json;
    }

    public String getJson()
    {
        return this.json;
    }
}
