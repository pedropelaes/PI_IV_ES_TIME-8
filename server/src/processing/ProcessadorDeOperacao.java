package src.processing;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.bson.Document;
import src.connection.IParceiro;
import src.domain.Aula;
import src.domain.Turma;
import src.domain.User;
import src.protocol.requests.*;
import src.protocol.responses.*;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class ProcessadorDeOperacao {
    private static final Gson gson = new Gson();

    public static boolean processar(String json, IParceiro remetente, ArrayList<IParceiro> usuarios){
        try{
            JsonObject obj = gson.fromJson(json, JsonObject.class);
            String tipo = obj.get("operacao").getAsString();
            System.out.println("Operação recebida: '" + tipo + "'");
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
                case "GetTurmas":
                    GetTurmas getTurmas = gson.fromJson(json, GetTurmas.class);
                    List<Turma> turmas = getTurmas.getTurmas();
                    boolean turmasEmpty = turmas != null;
                    remetente.receba(new ResultadoGetTurmas(turmasEmpty, "ResultadoGetTurmas", turmas));
                    break;
                case "RegistrarPresenca":
                    RegistrarPresenca registrarPresenca = gson.fromJson(json, RegistrarPresenca.class);
                    resultado = registrarPresenca.registrarPresenca();
                    String mensagem = registrarPresenca.getMensagem();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoRegistrarPresenca", mensagem));
                    break;
                case "FecharChamada":
                    System.out.println("CASE FecharChamada ACIONADO! JSON: " + json);
                    FecharChamada fecharChamada = gson.fromJson(json, FecharChamada.class);
                    System.out.println("Parsing FecharChamada concluído. Código: " + fecharChamada.getCodigoChamada());
                    resultado = fecharChamada.fechar();
                    System.out.println("Resultado FecharChamada: " + resultado);
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoFecharChamada"));
                    break;
                case "GetPresencas":
                    GetPresencas getPresencas = gson.fromJson(json, GetPresencas.class);
                    List<String> alunos = getPresencas.getPresencas();
                    boolean alunosNaoVazios = alunos != null && !alunos.isEmpty();
                    remetente.receba(new ResultadoGetPresencas(alunosNaoVazios, "ResultadoGetPresencas", alunos != null ? alunos : new ArrayList<>()));
                    break;
                case "GetAulas":
                    GetAulas getAulas = gson.fromJson(json, GetAulas.class);
                    List<Aula> aulas = getAulas.getAulasFromTurma();
                    boolean aulasNaoVazios = aulas != null && !aulas.isEmpty();
                    remetente.receba(new ResultadoGetAulas(aulasNaoVazios, "ResultadoGetAulas", aulas));
                    break;
                default:
                    System.err.println("Comunicado desconhecido: '" + tipo + "'");
                    System.err.println("JSON completo recebido: " + json);
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
