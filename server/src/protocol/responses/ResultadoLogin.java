package src.protocol.responses;

import src.domain.User;

public class ResultadoLogin extends ResultadoOperacao {
    private User user;

    public ResultadoLogin(boolean resultado, String operacao, User user) {
        super(resultado, operacao); // inicializa os campos do pai
        this.user = user;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
