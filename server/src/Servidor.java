package src;

import src.connection.AceitadoraDeConexao;
import src.connection.IParceiro;
import src.connection.ServidorWebSocket;
import src.processing.ProcessadorDeOperacao;
import src.protocol.ComunicadoDeDesligamento;
import src.util.Teclado;

import java.util.*;
import java.util.concurrent.*;

public class Servidor
{
    // map de codigoChamada -> ultimo timestamp recebido
    private static final ConcurrentMap<String, Long> chamadaHeartbeats = new ConcurrentHashMap<>();
    // scheduler para checar chamadas sem HeartBeat
    private static final ScheduledExecutorService heartbeatScheduler = Executors.newSingleThreadScheduledExecutor();

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
    /**
     * Os seguintes metodos servem no contexto desse servidor para em caso de perca de conexao com o cliente
     * fechar uma chamada que esteja em aberto, caso apos uma request de codigo temporario, demore mais de 30
     * segundos para outra request ser feita.
     */
    static {
        heartbeatScheduler.scheduleAtFixedRate(() -> {
            try {
                long now = System.currentTimeMillis();
                long timeoutMs = 30_000L; // timeout: 30s
                List<String> stale = new ArrayList<>();
                for (Map.Entry<String, Long> e : chamadaHeartbeats.entrySet()) {
                    if (now - e.getValue() > timeoutMs) {
                        stale.add(e.getKey());
                    }
                }
                for (String codigo : stale) {
                    chamadaHeartbeats.remove(codigo);
                    System.out.println("KeepAlive timeout para chamada " + codigo + " — fechando automaticamente.");

                    boolean closed = ProcessadorDeOperacao.fecharChamadaPorCodigo(codigo);
                    if (!closed) {
                        System.err.println("Falha ao fechar chamada " + codigo + " por timeout.");
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }, 10, 15, TimeUnit.SECONDS);
    }
    // este metodo registra o codigo da chamada no map do heartbeats
    public static void registrarHeartbeat(String codigoChamada, long timestampMillis) {
        if (codigoChamada == null) return;
        chamadaHeartbeats.put(codigoChamada, timestampMillis);
    }

    public static void removerHeartbeat(String codigoChamada) {
        if (codigoChamada == null) return;
        chamadaHeartbeats.remove(codigoChamada);
    }
}
