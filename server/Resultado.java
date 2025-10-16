public class Resultado extends Comunicado
{
    private String resultado;

    public Resultado (String resultado)
    {
        this.resultado = resultado;
    }

    public String getResultado()
    {
        return this.resultado;
    }
    
    public String toString ()
    {
		return this.resultado;
	}

}
