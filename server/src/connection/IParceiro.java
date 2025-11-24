package src.connection;

import src.protocol.Comunicado;

// essa interface foi criada para padronizar o Parceiro para Socket e o ParceiroWebSocket
public interface IParceiro {
    void receba(Comunicado comunicado) throws Exception;

    void adeus() throws Exception;
}
