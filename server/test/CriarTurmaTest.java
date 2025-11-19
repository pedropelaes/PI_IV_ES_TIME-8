import org.junit.jupiter.api.Test;
import src.domain.LocPadrao;
import src.protocol.requests.CriarTurma;

import static org.junit.jupiter.api.Assertions.*;

class CriarTurmaTest {

    @Test
    void deveRetornarFalseQuandoAtributosForemNulos() {
        // Estado inválido: todos os atributos nulos
        CriarTurma criar = new CriarTurma();

        boolean resultado = criar.criarTurma();

        assertFalse(resultado, "Deveria retornar false quando atributos obrigatórios são nulos");
    }

    @Test
    void deveLancarExcecaoQuandoNomeForNulo() {
        assertThrows(IllegalArgumentException.class, () -> {
            CriarTurma.gerarCodigo(null);
        }, "Deveria lançar exceção quando o nome for nulo");
    }

    @Test
    void deveLancarExcecaoQuandoNomeForVazio() {
        assertThrows(IllegalArgumentException.class, () -> {
            CriarTurma.gerarCodigo("   ");
        }, "Deveria lançar exceção quando o nome for vazio");
    }

    @Test
    void deveGerarCodigoNoFormatoCorreto() {
        String codigo = CriarTurma.gerarCodigo("Engenharia de Software");

        assertNotNull(codigo);
        assertTrue(codigo.matches("^[A-Z]{1,4}-\\d{4}-[12]-[A-Z0-9]{5}$"),
                "O código deve seguir o padrão PREFIXO-ANO-SEMESTRE-IDUNICO");
    }

    @Test
    void deveRetornarTrueQuandoTodosAtributosForemValidos() throws Exception {
        // Aqui usamos reflexão apenas para preencher os campos,
        // já que a classe não possui setters públicos.
        CriarTurma criar = new CriarTurma();
        var nomeField = CriarTurma.class.getDeclaredField("nome");
        var descField = CriarTurma.class.getDeclaredField("descricao");
        var opField = CriarTurma.class.getDeclaredField("operacao");
        var objField = CriarTurma.class.getDeclaredField("objectId");
        var locField = CriarTurma.class.getDeclaredField("localizacaoPadrao");

        nomeField.setAccessible(true);
        descField.setAccessible(true);
        opField.setAccessible(true);
        objField.setAccessible(true);
        locField.setAccessible(true);

        nomeField.set(criar, "Turma Teste");
        descField.set(criar, "Descrição da turma");
        opField.set(criar, "criar");
        objField.set(criar, "507f1f77bcf86cd799439011"); // ObjectId válido fictício
        locField.set(criar, new LocPadrao(10.5, 20.7));

        boolean resultado = criar.criarTurma();

        assertTrue(resultado, "Deveria retornar true quando todos os atributos são válidos");
    }
}