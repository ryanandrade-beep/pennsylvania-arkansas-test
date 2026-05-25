# Pennsylvania Arkansas Test — Automação de API

Suite de testes automatizados de API para a plataforma **HubMessage** (microserviços Arkansas).
Utiliza **Karate DSL 1.4.1** com **JUnit 5**, integrado ao **Qase TMS**.

---

## Estrutura de arquivos

```
src/test/resources/features/
├── health/
│   └── health.feature                   # Health checks de todos os serviços
├── channels/
│   ├── channels.feature                 # Criar e conectar canais (META_WHATSAPP, ZAPI_WHATSAPP)
│   ├── channels-platforms.feature       # Ativar/desativar plataformas (Instagram, Messenger, Telegram, Meta)
│   └── trial.feature                    # Verificação de status trial
├── barling/
│   └── barling-messages.feature         # Envio, encaminhamento e deleção de mensagens via Barling
├── messages/
│   └── messages.feature                 # Envio de todos os tipos de mensagem via canal Meta
├── templates/
│   ├── templates.feature                # CRUD de templates WhatsApp Business (staging)
│   └── templates-production.feature     # Templates adicionais (WABA 993644263088265)
├── newport/
│   ├── newport-channels.feature         # CRUD de canais via Newport
│   ├── newport-telegram.feature         # Ativação de Telegram via Newport
│   ├── newport-zapi-instances.feature   # Endpoints de instâncias Z-API
│   └── newport-zapi-groups.feature      # Gerenciamento de grupos WhatsApp Z-API
└── hermitage/
    └── hermitage.feature                # Auditoria, usuários, faturamento e administração
```

---

## Roadmap de APIs testadas

### Canais (`/v1/channels` — arkansas-newport + pennsylvania-frisco)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `POST` | `/v1/channels` | channels.feature | 500–508 | Criar canal (META_WHATSAPP, ZAPI_WHATSAPP, tipos inválidos) |
| `POST` | `/v1/channels/{id}/connect` | channels.feature | 510–513 | Conectar canal ao número de WhatsApp |
| `POST` | `/v1/channels` | trial.feature | 1100–1103 | Criar canal e verificar status trial |

### Plataformas de Canais (`/channels/{id}` — pennsylvania-hermitage)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `POST` | `/channels/{id}/activate-meta` | channels-platforms.feature | 600–603 | Ativar WhatsApp Meta num canal |
| `POST` | `/channels/{id}/deactivate-meta` | channels-platforms.feature | 604–605 | Desativar WhatsApp Meta |
| `POST` | `/channels/{id}/activate-instagram` | channels-platforms.feature | 610–613 | Ativar Instagram num canal |
| `POST` | `/channels/{id}/deactivate-instagram` | channels-platforms.feature | 614–615 | Desativar Instagram |
| `POST` | `/channels/{id}/list-messenger-pages` | channels-platforms.feature | 620–622 | Listar páginas do Facebook para Messenger |
| `POST` | `/channels/{id}/activate-messenger` | channels-platforms.feature | 630–633 | Ativar Messenger num canal |
| `POST` | `/channels/{id}/deactivate-messenger` | channels-platforms.feature | 634–635 | Desativar Messenger |
| `POST` | `/channels/{id}/activate-telegram` | channels-platforms.feature | 640–643 | Ativar Telegram num canal |
| `POST` | `/channels/{id}/deactivate-telegram` | channels-platforms.feature | 644–645 | Desativar Telegram |

### Mensagens — Barling (`/v1/channels/{id}/messages` — arkansas-barling)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `POST` | `/v1/channels/{id}/messages` | barling-messages.feature | 10–44 | Envio de mensagens (TEXT, IMAGE, AUDIO, VIDEO, CONTACT, STICKER, INTERACTIVE) |
| `POST` | `/v1/channels/{id}/messages/forward` | barling-messages.feature | — | Encaminhar mensagem |
| `DELETE` | `/v1/channels/{id}/messages/{msgId}` | barling-messages.feature | — | Deletar mensagem |

### Mensagens — Meta WhatsApp (`/v1/channels/{metaChannelId}/messages`)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1000–1004 | Enviar template aprovado |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1010–1014 | Enviar texto simples |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1020–1023 | Enviar imagem com legenda |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1030–1033 | Enviar áudio |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1040–1043 | Enviar vídeo com legenda |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1050–1053 | Enviar contato |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1060–1063 | Enviar sticker (webp) |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1070–1074 | Enviar botões de ação (URL + CALL) |
| `POST` | `/v1/channels/{id}/messages` | messages.feature | 1080–1084 | Enviar texto com botões de resposta rápida |

> **Obs:** Mensagens livres (TEXT, IMAGE, etc.) só funcionam dentro da janela de 24h.
> Fora da janela, usar TEMPLATE.

### Templates WhatsApp Business (`/whatsapp/businesses`)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `GET` | `/whatsapp/businesses` | templates.feature | 900–902 | Listar WABAs disponíveis |
| `GET` | `/whatsapp/businesses/{wabaId}/templates` | templates.feature | 910–913 | Listar templates do WABA |
| `POST` | `/whatsapp/businesses/{wabaId}/templates/sync` | templates.feature | 920–923 | Sincronizar templates com a Meta |
| `POST` | `/whatsapp/businesses/{wabaId}/templates` | templates.feature | 930–960 | Criar templates (Customizado, OTP, Cupom, Oferta, Permissão de chamada, Library, Carrossel, Catálogo, Checkout, MPM) |
| `PUT` | `/whatsapp/businesses/{wabaId}/templates/{id}` | templates.feature | 940–943 | Editar template existente |
| `DELETE` | `/whatsapp/businesses/{wabaId}/templates/{id}` | templates.feature | 950–953 | Deletar template |
| `GET` | `/whatsapp/businesses/{wabaId}/templates` | templates-production.feature | 1000–1002 | Listar templates (WABA staging) |
| `POST` | `/whatsapp/businesses/{wabaId}/templates` | templates-production.feature | 1010–1130 | Criar templates (HEADER IMAGE/VIDEO/DOC, PHONE_NUMBER, botões mistos, AUTH zero/one-tap, CAROUSEL, LIMITED_TIME_OFFER, Cupom) |

**Templates cobertos por tipo:**

| Tipo | Cenários | Feature |
|------|----------|---------|
| Customizado MARKETING | @qase.id=934 | templates.feature |
| Customizado UTILITY | @qase.id=945 | templates.feature |
| Autenticação OTP (COPY_CODE) | @qase.id=935 | templates.feature |
| Cupom (COPY_CODE button) | @qase.id=936 | templates.feature |
| Oferta por tempo limitado | @qase.id=937 | templates.feature |
| Permissão de chamada MARKETING | @qase.id=938 | templates.feature |
| Permissão de chamada UTILITY | @qase.id=946 | templates.feature |
| Template Library MARKETING (QUICK_REPLY) | @qase.id=939 | templates.feature |
| Template Library UTILITY (URL button) | @qase.id=947 | templates.feature |
| Carrossel de mídia | @qase.id=944 | templates.feature |
| Catálogo | @qase.id=948 | templates.feature |
| Botão de checkout (MPM) | @qase.id=949 | templates.feature |
| Carrossel de produtos | @qase.id=954 | templates.feature |
| Multi-produto (MPM) | @qase.id=955 | templates.feature |
| HEADER IMAGE MARKETING | @qase.id=1010 | templates-production.feature |
| HEADER IMAGE UTILITY | @qase.id=1011 | templates-production.feature |
| HEADER VIDEO | @qase.id=1020 | templates-production.feature |
| HEADER DOCUMENT | @qase.id=1030 | templates-production.feature |
| Botão PHONE_NUMBER MARKETING | @qase.id=1040 | templates-production.feature |
| Botão PHONE_NUMBER UTILITY | @qase.id=1041 | templates-production.feature |
| Botões mistos URL+PHONE+QUICK_REPLY | @qase.id=1050 | templates-production.feature |
| Botões URL+PHONE_NUMBER UTILITY | @qase.id=1051 | templates-production.feature |
| AUTHENTICATION zero_tap | @qase.id=1060 | templates-production.feature |
| AUTHENTICATION one_tap | @qase.id=1061 | templates-production.feature |
| HEADER TEXT dinâmico | @qase.id=1070 | templates-production.feature |
| Carrossel VIDEO | @qase.id=1080 | templates-production.feature |
| Carrossel misto IMAGE+VIDEO | @qase.id=1081 | templates-production.feature |
| Somente BODY MARKETING | @qase.id=1090 | templates-production.feature |
| Somente BODY UTILITY | @qase.id=1091 | templates-production.feature |
| Cupom com HEADER IMAGE | @qase.id=1100 | templates-production.feature |
| LIMITED_TIME_OFFER com HEADER IMAGE | @qase.id=1101 | templates-production.feature |

### Newport — Canais (`/v1/channels` — arkansas-newport)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `POST` | `/v1/channels` | newport-channels.feature | 100–142 | CRUD completo de canais |
| `PUT` | `/v1/channels/{id}/telegram/active` | newport-telegram.feature | 200–205 | Ativar Telegram no canal |

### Newport — Z-API Instâncias (`/v1/channels/{id}/zapi/instances`)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `GET` | `.../status` | newport-zapi-instances.feature | 300–461 | Status, QR Code, device, contatos, phone-exists, disconnect, fila, read-message, profile-picture |

### Newport — Z-API Grupos

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `POST` | `.../create-group` | newport-zapi-groups.feature | 500–591 | Criar/gerenciar grupos (add/remove participant, admin, leave, update name/photo/description) |

### Health Checks

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `GET` | `/` | health.feature | 1–8 | Health check de todos os microserviços (barling, conway-zapi, conway-telegram, conway-meta, newport) |

### Hermitage — Auditoria (`/hermitage/audit-events`)

> **O que foi testado na auditoria:**
> Os endpoints de auditoria exigem **JWT de sessão de usuário** (gerado via login no painel), não a secret key de integração (`sk_live_*`).
> Por isso, **todos os testes verificam que a API recusa corretamente** as requisições sem autenticação adequada.
>
> Especificamente foram testados:
> - `GET /hermitage/audit-events` sem auth → deve retornar **403**
> - `GET /hermitage/audit-events` com `sk_live` → deve retornar **403** (secret key não é JWT de sessão)
> - `GET /hermitage/audit-events` com `Bearer sk_live` → deve retornar **403**
> - `GET /hermitage/audit-events` com token inválido → deve retornar **403**
> - `GET /hermitage/audit-events/actions` sem auth → deve retornar **403**
> - `GET /hermitage/audit-events/actions` com `sk_live` → deve retornar **403**
>
> Esses testes garantem que o endpoint de auditoria **está protegido** e não expõe dados sem autenticação válida.

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `GET` | `/hermitage/audit-events` | hermitage.feature | 1200–1203 | Listar eventos de auditoria (todos negativos — exige JWT sessão) |
| `GET` | `/hermitage/audit-events/actions` | hermitage.feature | 1210–1211 | Listar ações disponíveis (negativos) |

### Hermitage — Usuários (`/hermitage/users`)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `GET` | `/hermitage/users/get-user` | hermitage.feature | 1220–1223 | Obter usuário atual (negativos — exige JWT sessão) |
| `PUT` | `/hermitage/users/update` | hermitage.feature | 1230–1234 | Atualizar dados do usuário (negativos) |
| `GET` | `/hermitage/users/v2` | hermitage.feature | 1250–1252 | Listar usuários paginado (admin) |
| `GET` | `/hermitage/users/partner` | hermitage.feature | 1253–1254 | Listar parceiros (admin) |
| `PUT` | `/hermitage/users/{id}/block` | hermitage.feature | 1260–1261 | Bloquear usuário (admin) |
| `PUT` | `/hermitage/users/{id}/unblock` | hermitage.feature | 1262–1263 | Desbloquear usuário (admin) |
| `POST` | `/hermitage/users/{id}/turn-partner` | hermitage.feature | 1270–1271 | Habilitar parceria (admin) |
| `POST` | `/hermitage/users/{id}/remove-partner` | hermitage.feature | 1272–1273 | Remover parceria (admin) |
| `POST` | `/hermitage/users/{id}/turn-into-pyramid` | hermitage.feature | 1280–1281 | Habilitar influencer/pyramid (admin) |

### Hermitage — Faturamento (`/hermitage/billing` + `/hermitage/person-bills`)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `PUT` | `/hermitage/person-bills` | hermitage.feature | 1240–1244 | Atualizar dados de faturamento (nome, CPF/CNPJ, endereço) |
| `GET` | `/hermitage/billing/invoices` | hermitage.feature | 1290–1292 | Listar faturas Stripe |
| `GET` | `/hermitage/billing/upcoming` | hermitage.feature | 1295–1296 | Próxima cobrança |
| `GET` | `/hermitage/billing/subscription-timeline` | hermitage.feature | 1298–1299 | Linha do tempo de assinaturas |

### Hermitage — Administração de Workspaces (`/hermitage/admin/workspaces`)

| Método | Rota | Feature | Qase IDs | Descrição |
|--------|------|---------|----------|-----------|
| `GET` | `/hermitage/admin/workspaces` | hermitage.feature | 1300–1302 | Listar workspaces (admin) |
| `POST` | `/hermitage/admin/workspaces/{id}/turn-partner` | hermitage.feature | 1310–1311 | Tornar workspace parceiro (admin) |
| `POST` | `/hermitage/admin/workspaces/{id}/remove-partner` | hermitage.feature | 1312–1313 | Remover parceria do workspace (admin) |

---

## Configuração de ambiente

### Arquivo `.env`

```
BASE_URL=https://api.staging.hubmessage.io
SECRET_KEY=sk_live_...
META_CHANNEL_ID=019E4C54B1B375A28970B605CA9B03C3
PHONE_NUMBER=5544936181064
BUSINESS_ID=993644263088265
TEMPLATE_NAME=teste_1
TEMPLATE_ID=1538401031323218

# IDs dos usuários de teste (apenas estes devem ser manipulados)
ADMIN_USER_ID_RYAN=3F1AF0B1471430BB940DD6E09DE4E657
ADMIN_USER_ID_PARCEIRO=019DF4A038077CE89B668C7EC4275B80
```

### Variável `karateSuffix` — Solução para templates duplicados

Toda execução dos testes cria templates novos. Como a API da Meta **não permite dois templates com o mesmo nome** no mesmo WABA, o Karate gera automaticamente um sufixo único baseado no timestamp da execução (`System.currentTimeMillis()`).

**Como funciona:**
- Em cada run, `karateSuffix` recebe o valor do timestamp atual (ex: `1748177432000`)
- Todos os nomes de templates nos feature files usam `#(karateSuffix)` no final
- Resultado: `karate_customizado_mkt_v1_1748177432000` — único por execução

**Uso nos feature files:**
```gherkin
And request
  """
  {
    "name": "karate_meu_template_v1_#(karateSuffix)",
    "category": "MARKETING",
    ...
  }
  """
```

---

## Como executar

```bash
# Todos os testes de regressão (ambiente staging)
./run.sh staging @regression

# Apenas templates
./run.sh staging @templates

# Apenas mensagens
./run.sh staging @messages

# Apenas canais
./run.sh staging @channels

# Apenas health checks
./run.sh staging @smoke

# Com Qase TMS (cria run e reporta resultados)
./run-tests-qase.sh staging @regression
```

---

## Cobertura total de cenários

| Feature file | Cenários | Tags |
|---|---|---|
| health.feature | 8 | @health @smoke @regression |
| channels.feature | 13 | @channels @regression |
| channels-platforms.feature | 23 | @channels @platforms @regression |
| trial.feature | 4 | @trial @regression |
| barling-messages.feature | 35 | @barling @regression |
| messages.feature | 41 | @messages @regression |
| templates.feature | 22 | @templates @regression |
| templates-production.feature | ~30 | @templates @regression |
| newport-channels.feature | 25 | @newport @channels @regression |
| newport-telegram.feature | 6 | @newport @telegram @regression |
| newport-zapi-instances.feature | 42 | @newport @zapi @regression |
| newport-zapi-groups.feature | 20 | @newport @zapi @groups @regression |
| hermitage.feature | ~60 | @hermitage @regression |
| **Total** | **~329** | |

---

## Relatório

Após execução, o relatório HTML do Karate fica disponível em:
```
target/karate-reports/karate-summary.html
```
Abra no navegador para ver o resultado completo com detalhes de cada cenário.
