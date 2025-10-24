package src;

import src.connection.AceitadoraDeConexao;
import src.connection.IParceiro;
import src.connection.ServidorWebSocket;
import src.protocol.ComunicadoDeDesligamento;
import src.util.Teclado;

import java.util.*;

public class Servidor
{
    public static String PORTA_TCP = "3000";
    public static int PORTA_WEB = 3001;
    
    public static void main (String[] args)
    {
        if (args.length>1)
        {
            System.err.println ("Uso esperado: java src.Servidor [PORTA]\n");
            return;
        }

        String portaTcp=Servidor.PORTA_TCP;
        
        if (args.length==1)
            portaTcp = args[0];

        ArrayList<IParceiro> usuarios =
        new ArrayList<> ();

        AceitadoraDeConexao aceitadoraDeConexaoTcp = null;
        try
        {
            aceitadoraDeConexaoTcp =
            new AceitadoraDeConexao(portaTcp, usuarios);
            aceitadoraDeConexaoTcp.start();
        }
        catch (Exception erro)
        {
            System.err.println ("Erro ao iniciar TCP: " + erro.getMessage() +  "Escolha uma porta apropriada e liberada para uso!\n");
            return;
        }

        ServidorWebSocket serverWebSocket = null;
        try{
            serverWebSocket = new ServidorWebSocket(PORTA_WEB, usuarios);
            serverWebSocket.start();
        }catch(Exception erro){
            System.err.println ("Erro ao iniciar WEB: " + erro.getMessage() +  "Escolha uma porta apropriada e liberada para uso!\n");
        }

        for(;;)
        {
            System.out.println ("O servidor esta ativo! Para desativa-lo,");
            System.out.println ("use o comando \"desativar\"\n");
            System.out.print   ("> ");

            String comando=null;
            try
            {
                comando = Teclado.getUmString();
            }
            catch (Exception erro)
            {}

            if (comando.toLowerCase().equals("desativar"))
            {
                synchronized (usuarios)
                {
                    ComunicadoDeDesligamento comunicadoDeDesligamento =
                    new ComunicadoDeDesligamento();
                    
                    for (IParceiro usuario:usuarios)
                    {
                        try
                        {
                            usuario.receba (comunicadoDeDesligamento);
                            usuario.adeus  ();
                        }
                        catch (Exception erro)
                        {}
                    }

                    try{
                        serverWebSocket.stop(1000);
                    }catch(InterruptedException erro){
                        System.err.println ("Erro ao desativar web socket: " + erro.getMessage());
                    }


                }

                System.out.println ("O servidor foi desativado!\n");
                System.exit(0);
            }
            else
                System.err.println ("Comando invalido!\n");
        }
    }
}
