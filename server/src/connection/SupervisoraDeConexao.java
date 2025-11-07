package src.connection;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import com.google.gson.Gson;
import src.processing.ProcessadorDeOperacao;
import src.protocol.ComunicadoJson;


public class SupervisoraDeConexao extends Thread
{
    private Parceiro usuario;
    private Socket              conexao;
    private ArrayList<IParceiro> usuarios;
    private Gson gson;


    public SupervisoraDeConexao
    (Socket conexao, ArrayList<IParceiro> usuarios)
    throws Exception
    {
        if (conexao==null)
            throw new Exception ("Conexao ausente");

        if (usuarios==null)
            throw new Exception ("Usuarios ausentes");

        this.conexao  = conexao;
        this.usuarios = usuarios;
        this.gson     = new Gson();
    }

    public void run ()
    {
        try{
            BufferedWriter transmissor = new BufferedWriter(
                    new OutputStreamWriter(this.conexao.getOutputStream(), StandardCharsets.UTF_8));
            BufferedReader receptor = new BufferedReader(
                    new InputStreamReader(this.conexao.getInputStream(), StandardCharsets.UTF_8));

            this.usuario =
                    new Parceiro (this.conexao,
                            receptor,
                            transmissor);

            synchronized (this.usuarios)
            {
                this.usuarios.add (this.usuario);
            }

            for(;;){
                ComunicadoJson comunicadoJson = (ComunicadoJson) this.usuario.envie ();

                if (comunicadoJson==null)
                    return;

                String json = comunicadoJson.getJson();
                boolean deveDesconectar = ProcessadorDeOperacao.processar(
                        json, this.usuario, this.usuarios
                );

                if(deveDesconectar) break;
            }
        }catch(Exception erro){
            System.err.println("Erro de supervisao: " + erro.getMessage());
            try { if (usuario != null) usuario.adeus(); } catch (Exception ignored) {}
        } finally {
            if(this.usuario != null){
                synchronized (this.usuarios){
                    this.usuarios.remove(this.usuario);
                }
                try{
                    this.usuario.adeus();
                }catch(Exception ignored){}
            }
            System.out.println("Cliente TCP desconectado: " + this.conexao.getRemoteSocketAddress());
        }

    }

}


