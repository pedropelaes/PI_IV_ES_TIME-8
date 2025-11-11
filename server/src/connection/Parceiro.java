package src.connection;

import java.io.*;
import java.net.*;
import java.util.concurrent.Semaphore;
import com.google.gson.Gson;
import src.protocol.Comunicado;
import src.protocol.ComunicadoJson;

public class Parceiro implements IParceiro
{
    private Socket             conexao;
    private BufferedReader   receptor;
    private BufferedWriter transmissor;
    private Gson gson;
    private /*src.protocol.Comunicado*/ String proximoComunicado=null;

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

    @Override
    public void receba (Comunicado x) throws Exception
    {
        try
        {
            String json = gson.toJson(x);
            System.out.println("Enviando resposta para app: " + json);
            this.transmissor.write (json + "\n");
            this.transmissor.flush ();
        }
        catch (IOException erro)
        {
            throw new Exception ("Erro de transmissao");
        }
    }

//    public src.protocol.Comunicado espie () throws Exception
//    {
//        try
//        {
//            this.mutEx.acquireUninterruptibly();
//            if (this.proximoComunicado==null) this.proximoComunicado = (src.protocol.Comunicado)this.receptor.read();
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

    @Override
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
