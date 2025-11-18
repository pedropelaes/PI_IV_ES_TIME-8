package test;

import org.junit.jupiter.api.Test;
import src.domain.Turma;
import src.protocol.requests.GetTurmas;

import java.util.List;
import java.util.ArrayList;

import static org.junit.jupiter.api.Assertions.*;

class GetTurmasTest {

    @Test
    void deveRetornarNullQuandoListaDeIdsForNula() {
        GetTurmas get = new GetTurmas("buscar", null);

        List<Turma> resultado = get.getTurmas();

        assertNull(resultado, "Deveria retornar null quando turmasId é nula");
    }

    @Test
    void deveRetornarListaVaziaQuandoNaoHaTurmas() {
        GetTurmas get = new GetTurmas("buscar", new ArrayList<>());

        List<Turma> resultado = get.getTurmas();

        assertNotNull(resultado);
        assertTrue(resultado.isEmpty(), "Deveria retornar lista vazia quando não há turmas cadastradas");
    }

    @Test
    void deveRetornarListaVaziaQuandoIdsInexistentes() {
        List<String> idsInvalidos = List.of("000000000000000000000000");
        GetTurmas get = new GetTurmas("buscar", idsInvalidos);

        List<Turma> resultado = get.getTurmas();

        assertNotNull(resultado, "O método deve retornar uma lista, mesmo se vazia");
        assertTrue(resultado.isEmpty(), "Deveria retornar lista vazia para IDs inexistentes");
    }

    @Test
    void deveRetornarTrueQuandoObjetosIguais() {
        List<String> ids = List.of("507f1f77bcf86cd799439011");
        GetTurmas g1 = new GetTurmas("buscar", ids);
        GetTurmas g2 = new GetTurmas("buscar", ids);

        assertTrue(g1.equals(g2), "Dois objetos com mesmos valores devem ser iguais");
        assertEquals(g1.hashCode(), g2.hashCode(), "Objetos iguais devem ter o mesmo hashCode");
    }
}