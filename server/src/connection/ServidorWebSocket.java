package src.connection;

import org.java_websocket.server.WebSocketServer;
import org.java_websocket.WebSocket;
import org.java_websocket.handshake.ClientHandshake;
import src.processing.ProcessadorDeOperacao;

import java.net.InetSocketAddress;
import java.util.ArrayList;

public class ServidorWebSocket extends WebSocketServer {
    private ArrayList<IParceiro> usuarios;

    public ServidorWebSocket(int porta, ArrayList<IParceiro> usuarios) {
        super(new InetSocketAddress("0.0.0.0", porta));
        this.usuarios = usuarios;
    }

    @Override
    public void onOpen(WebSocket conn, ClientHandshake handshake) {
        System.out.println("Nova conexão WebSocket de: " + conn.getRemoteSocketAddress());
        ParceiroWebSocket novoUsuario = new ParceiroWebSocket(conn);

        synchronized (usuarios) {
            this.usuarios.add(novoUsuario);
        }

        // Associa nosso objeto src.connection.Parceiro à conexão para fácil acesso futuro
        conn.setAttachment(novoUsuario);
    }

    @Override
    public void onClose(WebSocket conn, int code, String reason, boolean remote) {
        System.out.println("Conexão WebSocket fechada de: " + conn.getRemoteSocketAddress());
        IParceiro usuarioSaindo = conn.getAttachment();
        if (usuarioSaindo != null) {
            synchronized (usuarios) {
                this.usuarios.remove(usuarioSaindo);
            }
        }
    }

    @Override
    public void onMessage(WebSocket conn, String message) {
        IParceiro remetente = conn.getAttachment();

        if (remetente != null) {
            boolean deveDesconectar = ProcessadorDeOperacao.processar(message, remetente, this.usuarios);
            if (deveDesconectar) {
                try {
                    remetente.adeus();
                } catch (Exception ignored) {}
            }
        }
    }

    @Override
    public void onError(WebSocket conn, Exception ex) {
        System.err.println("Erro na conexão WebSocket: " + ex.getMessage());
        ex.printStackTrace();
        // A lógica onClose será chamada automaticamente após um erro.
    }

    @Override
    public void onStart() {
        System.out.println("src.Servidor WebSocket iniciado e escutando na porta: " + getPort());
    }

}
