package com.irrahgroup.arkansas;

import com.intuit.karate.RuntimeHook;
import com.intuit.karate.core.FeatureRuntime;
import com.intuit.karate.core.ScenarioResult;
import com.intuit.karate.core.ScenarioRuntime;
import com.intuit.karate.core.Step;
import com.intuit.karate.core.StepResult;
import com.intuit.karate.core.Tags;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.logging.Logger;

/**
 * QaseKarateHook — RuntimeHook do Karate que envia cada Scenario
 * individualmente ao Qase TMS via API REST v1.
 *
 * Funciona lendo a tag @qase.title=X de cada Scenario e publicando
 * o resultado (passed/failed) no run ativo do projeto pelo titulo.
 * Cria o caso automaticamente no Qase se nao existir.
 *
 * Variaveis necessarias (passadas via -D no Maven):
 *   QASE_MODE               — "testops" para ativar
 *   QASE_TESTOPS_API_TOKEN  — token de API do Qase
 *   QASE_TESTOPS_PROJECT    — codigo do projeto (ex: PA)
 *   QASE_TESTOPS_RUN_ID     — ID do run criado pelo run-tests-qase.sh
 */
public class QaseKarateHook implements RuntimeHook {

    private static final Logger log = Logger.getLogger(QaseKarateHook.class.getName());

    private final String apiToken;
    private final String projectCode;
    private final String runId;
    private final boolean enabled;
    private final HttpClient http;

    public QaseKarateHook() {
        this.apiToken    = env("QASE_TESTOPS_API_TOKEN", "");
        this.projectCode = env("QASE_TESTOPS_PROJECT",   "PA");
        this.runId       = env("QASE_TESTOPS_RUN_ID",    "");
        String mode      = env("QASE_MODE", "off");

        this.enabled = "testops".equalsIgnoreCase(mode)
                    && !apiToken.isEmpty()
                    && !runId.isEmpty();

        this.http = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();

        if (this.enabled) {
            log.info("[Qase] Hook ativo — projeto: " + projectCode + " | run: " + runId);
        } else {
            log.info("[Qase] Hook desativado (QASE_MODE=" + mode
                    + ", token=" + (apiToken.isEmpty() ? "vazio" : "ok")
                    + ", runId=" + (runId.isEmpty() ? "vazio" : runId) + ")");
        }
    }

    // ── Ciclo de vida do Scenario ────────────────────────────────────────────

    @Override
    public boolean beforeScenario(ScenarioRuntime sr) {
        return true;
    }

    @Override
    public void afterScenario(ScenarioRuntime sr) {
        if (!enabled) return;

        // Verifica se o Scenario tem tag @qase.id (marcado para Qase)
        Tags effectiveTags = sr.scenario.getTagsEffective();
        Tags.Values qaseIdValues = effectiveTags.valuesFor("qase.id");
        if (!qaseIdValues.isPresent() || qaseIdValues.values.isEmpty()) return;

        // Usa o nome do Scenario como titulo do caso no Qase
        // (o @qase.title nao funciona com espacos no Karate DSL)
        String caseTitle = sr.scenario.getName();

        ScenarioResult result = sr.result;
        String status  = result.isFailed() ? "failed" : "passed";
        String comment = buildComment(result);
        long   elapsed = (long) result.getDurationMillis();

        sendResult(caseTitle, status, comment, elapsed);
    }

    // ── Ciclo de vida da Feature ─────────────────────────────────────────────

    @Override
    public boolean beforeFeature(FeatureRuntime fr) { return true; }

    @Override
    public void afterFeature(FeatureRuntime fr) {}

    @Override
    public boolean beforeStep(Step step, ScenarioRuntime sr) { return true; }

    @Override
    public void afterStep(StepResult result, ScenarioRuntime sr) {}

    // ── Helpers ─────────────────────────────────────────────────────────────

    private String buildComment(ScenarioResult result) {
        if (result.isFailed() && result.getError() != null) {
            String msg = result.getError().getMessage();
            return msg != null ? msg.substring(0, Math.min(msg.length(), 500)) : "falhou";
        }
        return "";
    }

    private void sendResult(String caseTitle, String status, String comment, long elapsedMs) {
        String url = "https://api.qase.io/v1/result/" + projectCode + "/" + runId;

        String titleJson   = caseTitle.replace("\\", "\\\\").replace("\"", "\\\"");
        String commentJson = comment.replace("\\", "\\\\")
                                    .replace("\"", "\\\"")
                                    .replace("\n", "\\n")
                                    .replace("\r", "");

        // Envia com "case" inline — Qase vincula pelo titulo ou cria automaticamente
        String body = "{"
                + "\"case\":{\"title\":\"" + titleJson + "\"},"
                + "\"status\":\"" + status + "\","
                + "\"time_ms\":" + elapsedMs + ","
                + "\"comment\":\"" + commentJson + "\""
                + "}";

        try {
            HttpResponse<String> response = post(url, body);
            int code = response.statusCode();

            if (code == 200 || code == 201) {
                log.info("[Qase] \"" + caseTitle + "\" (" + status + ") enviado");
            } else if (code == 404 || (code >= 400 && response.body().contains("not found"))) {
                // Caso nao existe — cria e tenta novamente
                createCase(caseTitle);
                HttpResponse<String> retry = post(url, body);
                if (retry.statusCode() == 200 || retry.statusCode() == 201) {
                    log.info("[Qase] \"" + caseTitle + "\" (" + status + ") enviado (apos criar caso)");
                } else {
                    log.warning("[Qase] \"" + caseTitle + "\" — erro apos criar: "
                            + retry.statusCode() + " | " + retry.body());
                }
            } else {
                log.warning("[Qase] \"" + caseTitle + "\" — erro " + code
                        + " | " + response.body());
            }
        } catch (Exception e) {
            log.warning("[Qase] Erro ao enviar \"" + caseTitle + "\": " + e.getMessage());
        }
    }

    private HttpResponse<String> post(String url, String body) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Token", apiToken)
                .header("Content-Type", "application/json")
                .header("accept", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .timeout(Duration.ofSeconds(15))
                .build();
        return http.send(request, HttpResponse.BodyHandlers.ofString());
    }

    private void createCase(String caseTitle) {
        String url = "https://api.qase.io/v1/case/" + projectCode;
        String titleJson = caseTitle.replace("\\", "\\\\").replace("\"", "\\\"");
        String body = "{\"title\":\"" + titleJson + "\"}";
        try {
            HttpResponse<String> resp = post(url, body);
            if (resp.statusCode() == 200 || resp.statusCode() == 201) {
                log.info("[Qase] Caso criado: \"" + caseTitle + "\"");
            }
        } catch (Exception e) {
            log.warning("[Qase] Erro ao criar caso \"" + caseTitle + "\": " + e.getMessage());
        }
    }

    private static String env(String key, String defaultValue) {
        String v = System.getProperty(key);
        if (v != null && !v.isEmpty()) return v;
        v = System.getenv(key);
        return (v != null && !v.isEmpty()) ? v : defaultValue;
    }
}
