package com.irrahgroup.arkansas;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Runner principal da suite pennsylvania-arkansas-test.
 *
 * Executa todas as features em paralelo com 5 threads.
 * O QaseKarateHook envia cada Scenario individualmente ao Qase TMS.
 *
 * Para executar um subconjunto especifico, use as tags:
 *   mvn test -Dkarate.options="--tags @smoke"
 *   mvn test -Dkarate.options="--tags @barling"
 *   mvn test -Dkarate.options="--tags @newport"
 *   mvn test -Dkarate.options="--tags @conway"
 *   mvn test -Dkarate.options="--tags @regression"
 *
 * Para definir o ambiente:
 *   mvn test -Dkarate.env=staging
 *   mvn test -Dkarate.env=production
 *   mvn test -Dkarate.env=local
 *
 * Para enviar ao Qase, defina as variaveis de ambiente:
 *   QASE_MODE=testops
 *   QASE_TESTOPS_API_TOKEN=seu_token
 *   QASE_TESTOPS_PROJECT=PENNSYLVANIA
 *   QASE_TESTOPS_RUN_ID=id_do_run_criado
 */
public class TestRunner {

    @Test
    void testAll() {
        Results results = Runner.path("classpath:features")
                                .hook(new QaseKarateHook())
                                .parallel(5);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
