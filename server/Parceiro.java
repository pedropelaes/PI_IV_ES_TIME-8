import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.Semaphore;
import com.google.gson.Gson;

public class Parceiro
{
    private Socket             conexao;
    private BufferedReader   receptor;
    private BufferedWriter transmissor;
    private Gson gson;
    
    private /*Comunicado*/ String proximoComunicado=null;

    private Semaphore mutEx = new Semaphore (1,true);

    public Parceiro (Socket             conexao,
                     BufferedReader  receptor,
                     BufferedWriter transmissor)
                     throws Exception // se parametro nulos
    {
        if (conexao==null)
            throw new Exception ("Conexao ausente");

        if (receptor==null)
            throw new Exception ("Receptor ausente");

        if (transmissor==null)
            throw new Exception ("Transmissor ausente");

        this.conexao     = conexao;
        this.receptor    = receptor;
        this.transmissor = transmissor;
        this.gson = new Gson();
    }

    public void receba (Comunicado x) throws Exception
    {
        try
        {
            String json = gson.toJson(x);
            this.transmissor.write (json + "\n");
            this.transmissor.flush ();
        }
        catch (IOException erro)
        {
            throw new Exception ("Erro de transmissao");
        }
    }

//    public Comunicado espie () throws Exception
//    {
//        try
//        {
//            this.mutEx.acquireUninterruptibly();
//            if (this.proximoComunicado==null) this.proximoComunicado = (Comunicado)this.receptor.read();
//            this.mutEx.release();
//            return this.proximoComunicado;
//        }
//        catch (Exception erro)
//        {
//            throw new Exception ("Erro de recepcao");
//        }
//    }

    public Comunicado envie () throws Exception
    {
        try
        {

            if (this.proximoComunicado==null) this.proximoComunicado = this.receptor.readLine();
            if (this.proximoComunicado == null)
                throw new Exception("Conexão encerrada pelo cliente");

            String json = this.proximoComunicado;
            this.proximoComunicado = null;

            return new ComunicadoJson(json);
        }
        catch (Exception erro)
        {
            throw new Exception ("Erro de recepcao");
        }
    }

    public void adeus () throws Exception
    {
        try
        {
            this.transmissor.close();
            this.receptor   .close();
            this.conexao    .close();
        }
        catch (Exception erro)
        {
            throw new Exception ("Erro de desconexao");
        }
    }
}
