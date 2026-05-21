# Pennsylvania Arkansas Test

Testes automatizados de API para os servicos **Arkansas** (conway, barling, newport) da plataforma HubMessage, utilizando **Karate DSL** com integracao ao **Qase TMS** (projeto `PA`).

Estruturado no mesmo padrao do `pennsylvania-frisco-test`, com cenarios `Given / And / When / Then` cobrindo todos os 55 endpoints dos servicos arkansas.

---

## Requisitos

- **Java** >= 17
- **Maven** >= 3.8

---

## Instalando o projeto

```bash
git clone git@github.com:irrahgroup/pennsylvania-arkansas-test.git
cd pennsylvania-arkansas-test
mvn dependency:resolve
```

---

## Configurando as variaveis de ambiente

Crie o arquivo `.env` na raiz do projeto:

```env
# URL base
BASE_URL=https://api.hubmessage.io

# URLs diretas dos microservicos (opcional — fallback para BASE_URL)
CONWAY_ZAPI_URL=https://api.hubmessage.io
CONWAY_TELEGRAM_URL=https://api.hubmessage.io
CONWAY_META_URL=https://api.hubmessage.io
BARLING_URL=https://api.hubmessage.io
NEWPORT_URL=https://api.hubmessage.io

# Credenciais
SECRET_KEY=sk_live_sua_chave_aqui
PUBLIC_KEY=pk_live_sua_chave_aqui
ENTERPRISE_SECRET_KEY=sk_live_sua_chave_enterprise_aqui

# IDs de recursos para os testes
CHANNEL_ID=id_do_canal_meta
ZAPI_CHANNEL_ID=id_do_canal_zapi
TELEGRAM_CHANNEL_ID=id_do_canal_telegram
META_CHANNEL_ID=id_do_canal_meta_whatsapp
PHONE_NUMBER=5511999999999
MESSAGE_ID=id_de_uma_mensagem_existente
TELEGRAM_BOT_TOKEN=seu_bot_token_telegram

# IDs para testes de template
BUSINESS_ID=seu_business_id_meta
TEMPLATE_ID=id_do_template_aprovado
TEMPLATE_NAME=nome_do_template_aprovado

# Qase TMS — projeto PA (Pennsylvania)
QASE_TESTOPS_API_TOKEN=seu_token_qase_aqui
QASE_TESTOPS_PROJECT=PA
QASE_TESTOPS_RUN_TITLE="Automated test - API - run"
```

---

## Rodando os testes localmente

```bash
set -a && source .env && set +a
mvn test -Dkarate.env=production
```

### Por ambiente

```bash
mvn test -Dkarate.env=staging
mvn test -Dkarate.env=production
mvn test -Dkarate.env=local
```

### Por tag

```bash
# Smoke tests (execucao rapida)
mvn test -Dkarate.options="--tags @smoke"

# Por servico
mvn test -Dkarate.options="--tags @barling"
mvn test -Dkarate.options="--tags @newport"
mvn test -Dkarate.options="--tags @conway"

# Por tipo de canal
mvn test -Dkarate.options="--tags @zapi"
mvn test -Dkarate.options="--tags @telegram"
mvn test -Dkarate.options="--tags @meta"

# Por resultado esperado
mvn test -Dkarate.options="--tags @positive"
mvn test -Dkarate.options="--tags @negative"

# Suite completa
mvn test -Dkarate.options="--tags @regression"
```

---

## Rodando com Qase TMS

O script `run-tests-qase.sh` cria o run, executa os testes e fecha o run automaticamente. Cada Scenario e enviado individualmente via `QaseKarateHook`.

```bash
# Todos os testes (@regression)
./run-tests-qase.sh

# Por tag
./run-tests-qase.sh @smoke
./run-tests-qase.sh @barling
./run-tests-qase.sh @newport
./run-tests-qase.sh @conway

# Tag + ambiente + titulo personalizado
./run-tests-qase.sh @regression production "Automated test - API"
./run-tests-qase.sh @smoke staging "Manual test - Smoke"
```

---

## Como funciona a integracao com o Qase

O `QaseKarateHook` e um `RuntimeHook` do Karate registrado no `TestRunner`. Ao final de cada Scenario:

1. Le o nome do Scenario como titulo do caso
2. Envia `POST /v1/result/PA/{runId}` com status `passed` ou `failed`
3. Se o caso nao existir, cria automaticamente e reenvia

O `run-tests-qase.sh` orquestra:
1. `POST /v1/run/PA` — cria o run e captura o `RUN_ID`
2. `mvn test` — executa com `-DQASE_TESTOPS_RUN_ID={RUN_ID}`
3. `POST /v1/run/PA/{RUN_ID}/complete` — fecha o run

---

## Relatorio HTML

Apos a execucao, abra no navegador:

```
target/karate-reports/karate-summary.html
```

---

## Estrutura do projeto

```
pennsylvania-arkansas-test/
├── .github/workflows/ci.yml
├── src/test/
│   ├── java/com/irrahgroup/arkansas/
│   │   ├── TestRunner.java               # JUnit 5 runner com execucao paralela
│   │   └── QaseKarateHook.java           # RuntimeHook — envia cada Scenario ao Qase
│   └── resources/
│       ├── junit-platform.properties     # Ativa autodetection do JUnit 5
│       ├── karate-config.js              # Configuracao global (URLs, credenciais, env)
│       └── features/
│           ├── health/
│           │   └── health.feature         # Qase IDs: 1–8    | 8 cenarios
│           ├── barling/
│           │   └── barling-messages.feature   # Qase IDs: 10–44  | 35 cenarios
│           ├── conway/
│           │   ├── conway-zapi-webhooks.feature    # Qase IDs: 600–613 | 14 cenarios
│           │   ├── conway-telegram-webhooks.feature # Qase IDs: 700–705 | 6 cenarios
│           │   └── conway-meta-webhooks.feature    # Qase IDs: 800–841 | 16 cenarios
│           └── newport/
│               ├── newport-channels.feature         # Qase IDs: 100–142 | 25 cenarios
│               ├── newport-telegram.feature         # Qase IDs: 200–205 | 6 cenarios
│               ├── newport-zapi-instances.feature   # Qase IDs: 300–461 | 42 cenarios
│               └── newport-zapi-groups.feature      # Qase IDs: 500–591 | 20 cenarios
├── .env                                  # Variaveis de ambiente (nao versionado)
├── .gitignore
├── qase.config.json
├── run-tests-qase.sh                     # Script principal com Qase
├── run.sh                                # Script local sem Qase
└── pom.xml
```

**Total: 229 cenarios** em 11 feature files cobrindo todos os endpoints.

---

## Suites de teste e cobertura

| Feature | Servico | Endpoints | Qase IDs | Cenarios |
|---|---|---|---|---|
| `health` | barling / newport / conway | `GET /` `GET /health-check` | 1–8 | 8 |
| `barling-messages` | barling | `POST/DELETE /v1/channels/{id}/messages` `POST .../forward` | 10–44 | 35 |
| `newport-channels` | newport | `GET/POST/PUT/DELETE /v1/channels` `GET/POST/PUT/DELETE /v1/channels/{id}` | 100–142 | 25 |
| `newport-telegram` | newport | `PUT /v1/channels/{id}/telegram/active` | 200–205 | 6 |
| `newport-zapi-instances` | newport | 22 endpoints `/v1/channels/{id}/zapi/instances/*` | 300–461 | 42 |
| `newport-zapi-groups` | newport | 10 endpoints de grupos WhatsApp | 500–591 | 20 |
| `conway-zapi-webhooks` | conway-zapi | `POST .../zapi/webhooks` `POST .../zapi/webhooks/init-data` | 600–613 | 14 |
| `conway-telegram-webhooks` | conway-telegram | `POST .../telegram/webhooks` | 700–705 | 6 |
| `conway-meta-webhooks` | conway-meta/instagram/messenger/ml/email | 5 endpoints de webhook | 800–841 | 16 |
| `templates` | API principal | `GET/POST/PUT/DELETE /whatsapp/businesses/*` | 900–960 | 22 |
| `messages` | API principal | `POST /v1/channels/{id}/messages` (8 tipos) | 1000–1084 | 41 |

---

## Tags disponíveis

| Tag | Descricao |
|---|---|
| `@smoke` | Conjunto minimo para validacao rapida |
| `@regression` | Suite completa |
| `@positive` | Cenarios de sucesso (happy path) |
| `@negative` | Cenarios de erro (auth invalida, 404, 400) |
| `@health` | Health checks |
| `@barling` | Testes do servico barling |
| `@newport` | Testes do servico newport |
| `@conway` | Testes do servico conway |
| `@zapi` | Testes Z-API WhatsApp |
| `@telegram` | Testes Telegram |
| `@meta` | Testes Meta (WA / Instagram / Messenger) |
| `@channels` | CRUD de canais (newport) |
| `@groups` | Grupos WhatsApp (newport) |

---

## Pipeline CI/CD

Arquivo `.github/workflows/ci.yml`:
- **Trigger:** push em `main` ou execucao manual
- **Runtime:** `ubuntu-latest`, Java 17, Maven 3.8
- **Secrets necessarios:** `BASE_URL`, `SECRET_KEY`, `PUBLIC_KEY`, `ENTERPRISE_SECRET_KEY`, `CHANNEL_ID`, `ZAPI_CHANNEL_ID`, `TELEGRAM_CHANNEL_ID`, `META_CHANNEL_ID`, `PHONE_NUMBER`, `MESSAGE_ID`, `TELEGRAM_BOT_TOKEN`, `QASE_TESTOPS_API_TOKEN`, `QASE_TESTOPS_PROJECT`

---

## Servicos testados

| Servico | Funcao |
|---|---|
| `arkansas-barling` | Orquestracao de mensagens outbound |
| `arkansas-newport` | CRUD de canais + gerenciamento Z-API/Telegram |
| `arkansas-conway` | Gateway de webhooks inbound (Z-API, Telegram, Meta, ML, Email) |

---

## Relacionamento com outros projetos

| Projeto | Stack | Descricao |
|---|---|---|
| `pennsylvania-frisco-test` | Jest + Node.js | Suite para a API principal HubMessage — projeto de referencia |
| `pennsylvania-conway-test` | Jest + Node.js | Suite para canais Conway |
| `pennsylvania-arkansas-test` | **Karate + Java** | **Este projeto** — suite para os microservicos Arkansas |
