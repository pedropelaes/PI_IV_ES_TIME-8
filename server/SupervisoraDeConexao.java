import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;


public class SupervisoraDeConexao extends Thread
{
    private double              valor=0;
    private Parceiro            usuario;
    private Socket              conexao;
    private ArrayList<Parceiro> usuarios;
    private Gson gson;


    public SupervisoraDeConexao
    (Socket conexao, ArrayList<Parceiro> usuarios)
    throws Exception
    {
        if (conexao==null)
            throw new Exception ("Conexao ausente");

        if (usuarios==null)
            throw new Exception ("Usuarios ausentes");

        this.conexao  = conexao;
        this.usuarios = usuarios;
        this.gson     = new Gson();
    }

    public void run ()
    {
        try{
            BufferedWriter transmissor = new BufferedWriter(
                    new OutputStreamWriter(this.conexao.getOutputStream(), StandardCharsets.UTF_8));
            BufferedReader receptor = new BufferedReader(
                    new InputStreamReader(this.conexao.getInputStream(), StandardCharsets.UTF_8));

            this.usuario =
                    new Parceiro (this.conexao,
                            receptor,
                            transmissor);

            synchronized (this.usuarios)
            {
                this.usuarios.add (this.usuario);
            }

            for(;;){
                ComunicadoJson comunicadoJson = (ComunicadoJson) this.usuario.envie ();

                if (comunicadoJson==null)
                    return;

                String json = comunicadoJson.getJson();
                JsonObject obj = gson.fromJson(json, JsonObject.class);
                String tipo = obj.get("operacao").getAsString();
                boolean resultado;

                switch (tipo) {
                    case "PedidoParaSair":

                        synchronized (this.usuarios) {
                            resultado = this.usuarios.remove(this.usuario);
                        }
                        this.usuario.receba(new ResultadoOperacao(resultado,"LogOut"));
                        this.usuario.adeus();
                        return;
                    case "Cadastro":
                        Cadastro cadastro = gson.fromJson(json, Cadastro.class);
                        resultado = cadastro.criarDocumento();
                        this.usuario.receba(new ResultadoOperacao(resultado, "ResultadoCadastro"));
                        break;
                    case "Login":
                        Login login = gson.fromJson(json, Login.class);
                        User user = login.getUserData();
                        boolean userFound = user != null;
                        this.usuario.receba(new ResultadoLogin(userFound,"Login", user));
                        break;
                    default:
                        System.err.println("Comunicado desconhecido: " + tipo);
                        break;
                }
            }
        }catch(Exception erro){
            System.err.println("Erro de supervisao: " + erro.getMessage());
            try { if (usuario != null) usuario.adeus(); } catch (Exception ignored) {}
        }

    }

}


