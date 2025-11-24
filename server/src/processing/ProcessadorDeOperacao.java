package src.processing;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.bson.Document;
import src.Servidor;
import src.connection.IParceiro;
import src.domain.*;
import src.protocol.requests.*;
import src.protocol.responses.*;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class ProcessadorDeOperacao {
    private static final Gson gson = new Gson();

    public static boolean processar(String json, IParceiro remetente, ArrayList<IParceiro> usuarios){
        try{
            /**
             * Espera-se um json com um campo "operacao", especificando qual a a requisicao desejada pelo cliente
             * Para cada requisicao, há um caso no switch abaixo, onde eh instanciado a partir da desserializacao do
             * json vindo do cliente um objeto da classe da requisicao desejada.
             * Portanto, se torna necessario que haja no json um campo e valor para cada atributo private da classe da
             * requisicao.
             * Para cada requisicao, a resposta enviada para o app eh um Comunicado.
             * Para requisicoes de comando (ex: Registrar), eh retornado um objeto da classe ResultadoDeOperacao,
             * que apenas informa qual operacao foi realizada e o seu resultado.
             * Para requisicoes de consulta (ex: Login), elas recebem um objeto da sua respectiva classe de resposta, sendo
             * uma classe Resultado<nome da operacao>.
             * Os objetos sao serializados para json antes de serem realmente enviados para o cliente.
             * <p>
             * Sobre as classes de dominio(src/domain):
             * Essas classes atuam como Espelhos das classes do cliente. Elas garantem que o Json recebido/enviado seja
             * serializado corretamente, e ajudam na padronizacao e organizacao do servidor.
             * */
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
                    FecharChamada fecharChamada = gson.fromJson(json, FecharChamada.class);
                    fecharChamadaInterno(fecharChamada, remetente);
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
                case "GetAlunosSimples":
                    GetAlunosSimples getAlunos = gson.fromJson(json, GetAlunosSimples.class);
                    List<AlunoSimples> alunosSimples = getAlunos.getStudents();
                    boolean alunosNaoVazio = alunosSimples != null && !alunosSimples.isEmpty();
                    remetente.receba(new ResultadoGetAlunosSimples(alunosNaoVazio, "ResultadoGetAlunosSimples", alunosSimples));
                    break;
                case "ApagarTurma":
                    ApagarTurma apagarTurma = gson.fromJson(json, ApagarTurma.class);
                    resultado = apagarTurma.apagarTurma();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoApagarTurma"));
                    break;
                case "EditarTurma":
                    EditarTurma editarTurma = gson.fromJson(json, EditarTurma.class);
                    resultado = editarTurma.editarTurma();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoEditarTurma"));
                    break;
                case "GetCodigoTemporario":
                    GetCodigoTemporario getCodigoTemporario = gson.fromJson(json, GetCodigoTemporario.class);
                    String codigoTemporario = getCodigoTemporario.getCodigo();
                    resultado = codigoTemporario != null;

                    // registrando o 'heartBeat' do cliente
                    Servidor.registrarHeartbeat(getCodigoTemporario.getCodigoChamada(), System.currentTimeMillis());

                    remetente.receba(new ResultadoGetCodigoTemporario(
                            resultado,
                            "ResultadoGetCodigoTemporario",
                            codigoTemporario
                    ));
                    break;
                case "RegistrarNovaFace":
                    RegistrarNovaFace registrarNovaFace = gson.fromJson(json, RegistrarNovaFace.class);
                    resultado = registrarNovaFace.registrar();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoRegistrarNovaFace"));
                    break;
                case "EditarChamada":
                    EditarChamada editarChamada = gson.fromJson(json, EditarChamada.class);
                    resultado = editarChamada.editar();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoEditarChamada"));
                    break;
                case "DeletarChamada":
                    DeletarChamada deletarChamada = gson.fromJson(json, DeletarChamada.class);
                    resultado = deletarChamada.deletar();
                    remetente.receba(new ResultadoOperacao(resultado, "ResultadoDeletarChamada"));
                    break;
                case "GetRelatorioMensal":
                    GetRelatorioMensal getRelatorioMensal = gson.fromJson(json, GetRelatorioMensal.class);
                    RelatorioMensalTurma relatorio = getRelatorioMensal.gerarRelatorio();
                    resultado = relatorio != null;
                    remetente.receba(new ResultadoGetRelatorioMensal(
                            "ResultadoGetRelatorioMensal",
                            resultado,
                            relatorio
                        ));
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


    // requisicao de fechar chamada reutilizavel para cliente e heartBeat do serivodr
    private static boolean fecharChamadaInterno(FecharChamada req, IParceiro remetente) {
        try {
            boolean resultado = req.fechar();
            if (remetente != null) {
                remetente.receba(new ResultadoOperacao(resultado, "ResultadoFecharChamada"));
            }
            if (resultado) {
                Servidor.removerHeartbeat(req.getCodigoChamada());
            }
            return resultado;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean fecharChamadaPorCodigo(String codigoChamada) {
        try {
            FecharChamada req = new FecharChamada();
            req.setCodigoChamada(codigoChamada); // certifique-se de ter esse setter em FecharChamada
            return fecharChamadaInterno(req, null);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

}
