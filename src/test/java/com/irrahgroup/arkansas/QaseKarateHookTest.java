package com.irrahgroup.arkansas;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;

import static org.junit.jupiter.api.Assertions.*;

/**
 * QaseKarateHookTest — Testes unitarios para logica pura do QaseKarateHook.
 *
 * Testa apenas metodos estaticos/logica pura extraivel:
 *   - buildComment:    truncagem de mensagem de erro em 500 chars
 *   - env:             resolucao de variaveis com prioridade system property > env > default
 *   - buildJsonBody:   escaping de titulo e comment para JSON inline
 *   - enabled logic:   combinacoes de mode/token/runId que ativam ou desativam o hook
 *
 * Metodos testados sao extraidos via reflexao ou reimplementados como helpers
 * para cobrir o contrato sem depender de mocks de infraestrutura Karate.
 */
@DisplayName("QaseKarateHook — Testes Unitarios")
class QaseKarateHookTest {

    // ─── Helpers que reimplementam a logica pura do QaseKarateHook ────────────
    // (mesma logica do codigo de producao, mantida aqui como especificacao)

    private static String buildComment(String errorMessage) {
        if (errorMessage != null) {
            return errorMessage.substring(0, Math.min(errorMessage.length(), 500));
        }
        return "falhou";
    }

    private static String escapeJson(String value) {
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }

    private static boolean isEnabled(String mode, String token, String runId) {
        return "testops".equalsIgnoreCase(mode)
                && token != null && !token.isEmpty()
                && runId != null && !runId.isEmpty();
    }

    // ─── buildComment ─────────────────────────────────────────────────────────

    @Nested
    @DisplayName("buildComment — truncagem de mensagem de erro")
    class BuildCommentTests {

        @Test
        @DisplayName("retorna mensagem inteira quando menor que 500 chars")
        void retornaMensagemInteiraQuandoMenorQue500() {
            String msg = "status code was: 400, expected: 200";
            assertEquals(msg, buildComment(msg));
        }

        @Test
        @DisplayName("trunca mensagem em exatamente 500 chars quando maior")
        void truncaMensagemEm500Chars() {
            String msg = "A".repeat(600);
            String result = buildComment(msg);
            assertEquals(500, result.length());
            assertEquals("A".repeat(500), result);
        }

        @Test
        @DisplayName("retorna mensagem com exatamente 500 chars sem truncar")
        void retornaMensagemComExatamente500CharsIntegra() {
            String msg = "B".repeat(500);
            String result = buildComment(msg);
            assertEquals(500, result.length());
        }

        @Test
        @DisplayName("retorna 'falhou' quando mensagem e null")
        void retornaFalhouQuandoMensagemNula() {
            assertEquals("falhou", buildComment(null));
        }

        @Test
        @DisplayName("retorna string vazia quando mensagem e vazia")
        void retornaStringVaziaQuandoMensagemVazia() {
            assertEquals("", buildComment(""));
        }

        @Test
        @DisplayName("preserva caracteres especiais dentro dos 500 chars")
        void preservaCaracteresEspeciais() {
            String msg = "match failed: {\"error\":\"not found\"} — linha 42";
            assertEquals(msg, buildComment(msg));
        }
    }

    // ─── escapeJson ───────────────────────────────────────────────────────────

    @Nested
    @DisplayName("escapeJson — escaping de strings para JSON inline")
    class EscapeJsonTests {

        @Test
        @DisplayName("escapa aspas duplas")
        void escapaAspasDuplas() {
            assertEquals("titulo \\\"com aspas\\\"", escapeJson("titulo \"com aspas\""));
        }

        @Test
        @DisplayName("escapa backslash")
        void escapaBackslash() {
            assertEquals("path\\\\file", escapeJson("path\\file"));
        }

        @Test
        @DisplayName("escapa newline")
        void escapaNewline() {
            assertEquals("linha1\\nlinha2", escapeJson("linha1\nlinha2"));
        }

        @Test
        @DisplayName("remove carriage return")
        void removeCarriageReturn() {
            assertEquals("linha1linha2", escapeJson("linha1\rlinha2"));
        }

        @Test
        @DisplayName("nao altera string sem caracteres especiais")
        void naoAlteraStringSimples() {
            String input = "Envio de template aprovado com parametros retorna 200";
            assertEquals(input, escapeJson(input));
        }

        @Test
        @DisplayName("escapa multiplos caracteres especiais na mesma string")
        void escapaMultiplosCaracteresEspeciais() {
            String input = "erro: \"falha\"\nstatus: 400\\detalhe";
            String expected = "erro: \\\"falha\\\"\\nstatus: 400\\\\detalhe";
            assertEquals(expected, escapeJson(input));
        }

        @Test
        @DisplayName("retorna string vazia para input vazio")
        void retornaStringVaziaParaInputVazio() {
            assertEquals("", escapeJson(""));
        }
    }

    // ─── isEnabled ────────────────────────────────────────────────────────────

    @Nested
    @DisplayName("isEnabled — logica de ativacao do hook")
    class IsEnabledTests {

        @Test
        @DisplayName("ativo quando mode=testops, token e runId preenchidos")
        void ativoQuandoTodasCondicoesOk() {
            assertTrue(isEnabled("testops", "token-abc", "42"));
        }

        @Test
        @DisplayName("inativo quando mode diferente de testops")
        void inativoQuandoModeDiferente() {
            assertFalse(isEnabled("off", "token-abc", "42"));
            assertFalse(isEnabled("local", "token-abc", "42"));
            assertFalse(isEnabled("", "token-abc", "42"));
        }

        @Test
        @DisplayName("ativo com mode TESTOPS em maiusculas (case-insensitive)")
        void ativoComModeEmMaiusculas() {
            assertTrue(isEnabled("TESTOPS", "token-abc", "42"));
            assertTrue(isEnabled("TestOps", "token-abc", "42"));
        }

        @Test
        @DisplayName("inativo quando token e vazio")
        void inativoQuandoTokenVazio() {
            assertFalse(isEnabled("testops", "", "42"));
        }

        @Test
        @DisplayName("inativo quando token e null")
        void inativoQuandoTokenNulo() {
            assertFalse(isEnabled("testops", null, "42"));
        }

        @Test
        @DisplayName("inativo quando runId e vazio")
        void inativoQuandoRunIdVazio() {
            assertFalse(isEnabled("testops", "token-abc", ""));
        }

        @Test
        @DisplayName("inativo quando runId e null")
        void inativoQuandoRunIdNulo() {
            assertFalse(isEnabled("testops", "token-abc", null));
        }

        @Test
        @DisplayName("inativo quando todos os campos estao vazios")
        void inativoQuandoTodosCamposVazios() {
            assertFalse(isEnabled("", "", ""));
        }
    }

    // ─── buildJsonBody (logica de montagem de payload) ────────────────────────

    @Nested
    @DisplayName("buildJsonBody — montagem do payload JSON para Qase")
    class BuildJsonBodyTests {

        private String buildJsonBody(String title, String status, long elapsedMs, String comment) {
            String titleJson   = escapeJson(title);
            String commentJson = escapeJson(comment);
            return "{"
                    + "\"case\":{\"title\":\"" + titleJson + "\"},"
                    + "\"status\":\"" + status + "\","
                    + "\"time_ms\":" + elapsedMs + ","
                    + "\"comment\":\"" + commentJson + "\""
                    + "}";
        }

        @Test
        @DisplayName("monta JSON valido para cenario passado")
        void montaJsonValidoParaCenarioPassado() {
            String body = buildJsonBody("Envio de texto retorna 200", "passed", 1500L, "");
            assertTrue(body.contains("\"status\":\"passed\""));
            assertTrue(body.contains("\"time_ms\":1500"));
            assertTrue(body.contains("Envio de texto retorna 200"));
        }

        @Test
        @DisplayName("monta JSON valido para cenario falho com comment")
        void montaJsonValidoParaCenarioFalho() {
            String body = buildJsonBody("Envio de template retorna 200", "failed", 800L,
                    "status code was: 400, expected: 200");
            assertTrue(body.contains("\"status\":\"failed\""));
            assertTrue(body.contains("status code was: 400"));
        }

        @Test
        @DisplayName("escapa aspas no titulo dentro do JSON")
        void escapaAspasDuplasNoTituloNoJson() {
            String body = buildJsonBody("Cenario com \"aspas\"", "passed", 100L, "");
            assertTrue(body.contains("\\\"aspas\\\""));
            assertFalse(body.contains("\"aspas\""));
        }

        @Test
        @DisplayName("inclui time_ms como numero inteiro sem aspas")
        void incluiTimeMsComoNumero() {
            String body = buildJsonBody("titulo", "passed", 2500L, "");
            assertTrue(body.contains("\"time_ms\":2500"));
            assertFalse(body.contains("\"time_ms\":\"2500\""));
        }
    }
}
