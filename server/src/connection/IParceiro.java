package src.connection;

import src.protocol.Comunicado;

public interface IParceiro {
    void receba(Comunicado comunicado) throws Exception;

    void adeus() throws Exception;
}
