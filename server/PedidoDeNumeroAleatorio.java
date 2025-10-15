public class PedidoDeNumeroAleatorio extends Comunicado
{
    private double valor;

    public PedidoDeNumeroAleatorio ()
    {
        this.valor    = (int)(Math.random()*6)+3;
    }

    public double getValor ()
    {
        return this.valor;
    }

    public String toString ()
    {
        return (""+this.valor);
    }
}
