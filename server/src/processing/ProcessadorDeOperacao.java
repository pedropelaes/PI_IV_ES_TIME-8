package src.processing;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import src.connection.IParceiro;
import src.domain.User;
import src.protocol.requests.*;
import src.protocol.responses.ResultadoAbrirChamada;
import src.protocol.responses.ResultadoLogin;
import src.protocol.responses.ResultadoOperacao;

import java.lang.reflect.Type;
import java.util.ArrayList;

public class ProcessadorDeOperacao {
    private static final Gson gson = new Gson();

    public static boolean processar(String json, IParceiro remetente, ArrayList<IParceiro> usuarios){
        try{
            JsonObject obj = gson.fromJson(json, JsonObject.class);
            String tipo = obj.get("operacao").getAsString();
            boolean resultado;

            switch (tipo) {
                case "PedidoParaSair":

                    synchronized (usuarios) {
                        resultado = usuarios.remove(remetente);
                    }
                    remetente.receba(new ResultadoOperacao(resultado,"LogOut"));
                    return true;
                case "Cadastro":
                    Cadastro cadastro = gson.fromJson(json, Cadastro.class);
                    resultado = cadastro.criarDocumento();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoCadastro"));
                    break;
                case "Login":
                    Login login = gson.fromJson(json, Login.class);
                    User user = login.getUserData();
                    boolean userFound = user != null;
                    remetente.receba(new ResultadoLogin(userFound,"ResultadoLogin", user));
                    break;
                case "CriarTurma":
                    CriarTurma criarTurma = gson.fromJson(json, CriarTurma.class);
                    resultado = criarTurma.criarTurma();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoCriarTurma"));
                    break;
                case "EntrarEmTurma":
                    EntrarEmTurma entrarEmTurma = gson.fromJson(json, EntrarEmTurma.class);
                    resultado = entrarEmTurma.entrar();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoEntrarEmTurma"));
                    break;
                case "AbrirChamada":
                    AbrirChamada abrirChamada = gson.fromJson(json, AbrirChamada.class);
                    String codigoChamada = abrirChamada.abrir();
                    boolean codigoChamadaNotNull = codigoChamada != null;
                    remetente.receba(new ResultadoAbrirChamada(codigoChamadaNotNull,"ResultadoAbrirChamada", codigoChamada));
                    break;

                default:
                    System.err.println("Comunicado desconhecido: " + tipo);
                    break;
            }
        } catch (Exception e) {
            System.err.println("Erro ao processar comunicado: " + e.getMessage());
            e.printStackTrace();
            return true;
        }

        return false;
    }

}
