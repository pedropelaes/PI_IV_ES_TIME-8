package src.connection;

import com.google.gson.Gson;

import org.java_websocket.WebSocket;
import src.protocol.Comunicado;

public class ParceiroWebSocket implements IParceiro {
    private WebSocket conexao;
    private Gson gson;

    public ParceiroWebSocket(WebSocket conexao) {
        this.conexao = conexao;
        this.gson = new Gson();
    }

    @Override
    public void receba(Comunicado comunicado) throws Exception {
        if (conexao != null && conexao.isOpen()) {
            String json = gson.toJson(comunicado);
            System.out.println("Enviando resposta para cliente: " + json);
            conexao.send(json);
        } else {
            System.out.println("Conexão não está aberta! Não é possível enviar resposta.");
        }
    }

    @Override
    public void adeus() throws Exception {
        if (conexao != null && conexao.isOpen()) {
            conexao.close();
        }
    }

}
