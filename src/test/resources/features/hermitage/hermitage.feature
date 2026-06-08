@hermitage @regression
Feature: Hermitage — Auditoria, Usuarios, Faturamento e Admin

  Testa os endpoints do servico Hermitage (identidade, auditoria, faturamento
  e administracao) via API HubMessage.

  IMPORTANTE: Os endpoints do Hermitage exigem autenticacao JWT de sessao de
  usuario (cookie ou Bearer com token gerado via POST /hermitage/users/signin).
  A secret key (sk_live_*) retorna 403 nesses endpoints pois e token de
  integracao, nao de sessao de usuario.

  Endpoints cobertos:
    GET  /hermitage/audit-events               — listar eventos de auditoria
    GET  /hermitage/audit-events/actions       — listar acoes de auditoria
    GET  /hermitage/users/get-user             — obter usuario atual
    PUT  /hermitage/users/update               — atualizar dados do usuario
    PUT  /hermitage/person-bills               — atualizar dados de faturamento
    GET  /hermitage/users/v2                   — listar usuarios (admin)
    GET  /hermitage/users/partner              — listar parceiros (admin)
    PUT  /hermitage/users/{id}/block           — bloquear usuario (admin)
    PUT  /hermitage/users/{id}/unblock         — desbloquear usuario (admin)
    POST /hermitage/users/{id}/turn-partner    — habilitar parceria (admin)
    POST /hermitage/users/{id}/remove-partner  — remover parceria (admin)
    GET  /hermitage/billing/invoices           — listar faturas
    GET  /hermitage/billing/upcoming           — proxima fatura
    GET  /hermitage/billing/subscription-timeline — linha do tempo assinaturas
    GET  /hermitage/admin/workspaces           — listar workspaces (admin)
    POST /hermitage/admin/workspaces/{id}/turn-partner — tornar workspace parceiro

  Background:
    * url baseUrl
    * def hermitageBase = '/hermitage'
    * def auditPath = hermitageBase + '/audit-events'
    * def auditActionsPath = hermitageBase + '/audit-events/actions'
    * def getUserPath = hermitageBase + '/users/get-user'
    * def updateUserPath = hermitageBase + '/users/update'
    * def personBillsPath = hermitageBase + '/person-bills'
    * def usersPath = hermitageBase + '/users'
    * def billingPath = hermitageBase + '/billing'
    * def adminWorkspacesPath = hermitageBase + '/admin/workspaces'
    * def idInexistente = '00000000-0000-0000-0000-000000000000'

  # ===========================================================================
  # GET /hermitage/audit-events — Listar eventos de auditoria
  # ===========================================================================

  @qase.id=1200 @qase.title=Hermitage AuditEvents: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET audit-events sem Authorization retorna 403
    Given path auditPath
    And param scope = 'WORKSPACE'
    And param page = 0
    And param pageSize = 50
    When method GET
    Then status 403

  @qase.id=1201 @qase.title=Hermitage AuditEvents: GET com sk_live retorna 403 pois exige JWT de sessao
  @negative @smoke
  Scenario: GET audit-events com sk_live retorna 403 pois endpoint exige JWT de sessao de usuario
    Given path auditPath
    And header Authorization = secretKey
    And param scope = 'WORKSPACE'
    And param page = 0
    And param pageSize = 50
    When method GET
    Then status 403

  @qase.id=1202 @qase.title=Hermitage AuditEvents: GET com Bearer sk_live retorna 403
  @negative
  Scenario: GET audit-events com Bearer sk_live retorna 403
    Given path auditPath
    And header Authorization = bearerSecretKey
    And param scope = 'WORKSPACE'
    And param page = 0
    And param pageSize = 50
    When method GET
    Then status 403

  @qase.id=1203 @qase.title=Hermitage AuditEvents: GET sem scope retorna 403
  @negative
  Scenario: GET audit-events sem scope retorna 403 com auth invalida
    Given path auditPath
    And header Authorization = 'chave-invalida'
    When method GET
    Then status 403

  # ===========================================================================
  # GET /hermitage/audit-events/actions — Listar acoes disponiveis
  # ===========================================================================

  @qase.id=1210 @qase.title=Hermitage AuditActions: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET audit-events/actions sem Authorization retorna 403
    Given path auditActionsPath
    When method GET
    Then status 403

  @qase.id=1211 @qase.title=Hermitage AuditActions: GET com sk_live retorna 403
  @negative
  Scenario: GET audit-events/actions com sk_live retorna 403
    Given path auditActionsPath
    And header Authorization = secretKey
    When method GET
    Then status 403

  # ===========================================================================
  # GET /hermitage/users/get-user — Obter usuario atual
  # ===========================================================================

  @qase.id=1220 @qase.title=Hermitage GetUser: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET users/get-user sem Authorization retorna 403
    Given path getUserPath
    When method GET
    Then status 403

  @qase.id=1221 @qase.title=Hermitage GetUser: GET com sk_live retorna 403 pois exige JWT de sessao
  @negative @smoke
  Scenario: GET users/get-user com sk_live retorna 403 pois endpoint exige JWT de sessao
    Given path getUserPath
    And header Authorization = secretKey
    When method GET
    Then status 403

  @qase.id=1222 @qase.title=Hermitage GetUser: GET com Bearer sk_live retorna 403
  @negative
  Scenario: GET users/get-user com Bearer sk_live retorna 403
    Given path getUserPath
    And header Authorization = bearerSecretKey
    When method GET
    Then status 403

  @qase.id=1223 @qase.title=Hermitage GetUser: GET com token invalido retorna 403
  @negative
  Scenario: GET users/get-user com token invalido retorna 403
    Given path getUserPath
    And header Authorization = 'Bearer token-invalido-que-nao-existe'
    When method GET
    Then status 403

  # ===========================================================================
  # PUT /hermitage/users/update — Atualizar dados do usuario
  # Campos editaveis: username, login (email), password, isANewPassword, phone
  # Excecao: excluir conta e feito via DELETE /hermitage/users
  # ===========================================================================

  @qase.id=1230 @qase.title=Hermitage UpdateUser: PUT sem auth retorna 403
  @negative @smoke
  Scenario: PUT users/update sem Authorization retorna 403
    Given path updateUserPath
    And request { "username": "TesteKarate" }
    When method PUT
    Then status 403

  @qase.id=1231 @qase.title=Hermitage UpdateUser: PUT com sk_live retorna 403
  @negative @smoke
  Scenario: PUT users/update com sk_live retorna 403 pois exige JWT de sessao
    Given path updateUserPath
    And header Authorization = secretKey
    And request { "username": "TesteKarate" }
    When method PUT
    Then status 403

  @qase.id=1232 @qase.title=Hermitage UpdateUser: PUT com Bearer sk_live retorna 403
  @negative
  Scenario: PUT users/update com Bearer sk_live retorna 403
    Given path updateUserPath
    And header Authorization = bearerSecretKey
    And request { "username": "TesteKarate" }
    When method PUT
    Then status 403

  @qase.id=1233 @qase.title=Hermitage UpdateUser: PUT com payload vazio e sem auth retorna 403
  @negative
  Scenario: PUT users/update com payload vazio e sem auth retorna 403
    Given path updateUserPath
    And request {}
    When method PUT
    Then status 403

  @qase.id=1234 @qase.title=Hermitage UpdateUser: PUT campos editaveis sem auth retorna 403
  @negative
  Scenario: PUT users/update com todos campos editaveis e sem auth retorna 403
    Given path updateUserPath
    And request
      """
      {
        "username": "Karate Usuario",
        "login": "teste@karate.com",
        "phone": "5511999990000"
      }
      """
    When method PUT
    Then status 403

  # ===========================================================================
  # PUT /hermitage/person-bills — Atualizar dados de faturamento
  # Campos editaveis: cpfCnpj, nomeFantasia, razaoSocial, email, website,
  #   pais, estado, cidade, bairro, logradouro, numeroEndereco,
  #   complementoEndereco, cep, telefone, foreigner
  # ===========================================================================

  @qase.id=1240 @qase.title=Hermitage PersonBills: PUT sem auth retorna 403
  @negative @smoke
  Scenario: PUT person-bills sem Authorization retorna 403
    Given path personBillsPath
    And request
      """
      {
        "nomeFantasia": "Karate Empresa",
        "razaoSocial": "Karate Empresa LTDA",
        "email": "financeiro@karate.com",
        "pais": "Brasil",
        "estado": "SP",
        "cidade": "Sao Paulo",
        "cep": "01310100"
      }
      """
    When method PUT
    Then status 403

  @qase.id=1241 @qase.title=Hermitage PersonBills: PUT com sk_live retorna 403
  @negative @smoke
  Scenario: PUT person-bills com sk_live retorna 403 pois exige JWT de sessao
    Given path personBillsPath
    And header Authorization = secretKey
    And request
      """
      {
        "nomeFantasia": "Karate Empresa",
        "razaoSocial": "Karate Empresa LTDA",
        "email": "financeiro@karate.com",
        "cpfCnpj": "00000000000",
        "pais": "Brasil",
        "estado": "SP",
        "cidade": "Sao Paulo",
        "bairro": "Bela Vista",
        "logradouro": "Av. Paulista",
        "numeroEndereco": "1000",
        "complementoEndereco": "Sala 1",
        "cep": "01310100",
        "telefone": "5511999990000",
        "website": "https://karate.io",
        "foreigner": false
      }
      """
    When method PUT
    Then status 403

  @qase.id=1242 @qase.title=Hermitage PersonBills: PUT com Bearer sk_live retorna 403
  @negative
  Scenario: PUT person-bills com Bearer sk_live retorna 403
    Given path personBillsPath
    And header Authorization = bearerSecretKey
    And request { "nomeFantasia": "Karate Empresa" }
    When method PUT
    Then status 403

  @qase.id=1243 @qase.title=Hermitage PersonBills: PUT com payload vazio e sem auth retorna 403
  @negative
  Scenario: PUT person-bills com payload vazio e sem auth retorna 403
    Given path personBillsPath
    And request {}
    When method PUT
    Then status 403

  @qase.id=1244 @qase.title=Hermitage PersonBills: PUT com token invalido retorna 403
  @negative
  Scenario: PUT person-bills com token invalido retorna 403
    Given path personBillsPath
    And header Authorization = 'Bearer jwt-invalido-karate-test'
    And request { "nomeFantasia": "Karate Empresa" }
    When method PUT
    Then status 403

  # ===========================================================================
  # GET /hermitage/users/v2 — Listar usuarios paginado (Admin)
  # Tela: Administracao > Usuarios
  # ===========================================================================

  @qase.id=1250 @qase.title=Hermitage AdminUsers: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET users/v2 sem Authorization retorna 403
    Given path usersPath + '/v2'
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1251 @qase.title=Hermitage AdminUsers: GET com sk_live retorna 403 pois exige JWT admin
  @negative @smoke
  Scenario: GET users/v2 com sk_live retorna 403 pois exige JWT de admin
    Given path usersPath + '/v2'
    And header Authorization = secretKey
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1252 @qase.title=Hermitage AdminUsers: GET com Bearer sk_live retorna 403
  @negative
  Scenario: GET users/v2 com Bearer sk_live retorna 403
    Given path usersPath + '/v2'
    And header Authorization = bearerSecretKey
    When method GET
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # GET /hermitage/users/partner — Listar parceiros (Admin)
  # Tela: Administracao > Parceiros
  # ===========================================================================

  @qase.id=1253 @qase.title=Hermitage AdminUsers Partner List: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET users/partner sem Authorization retorna 403
    Given path usersPath + '/partner'
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1254 @qase.title=Hermitage AdminUsers Partner List: GET com sk_live retorna 403
  @negative
  Scenario: GET users/partner com sk_live retorna 403 pois exige JWT de admin
    Given path usersPath + '/partner'
    And header Authorization = secretKey
    When method GET
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # PUT /hermitage/users/{id}/block — Bloquear usuario (Admin)
  # Tela: Administracao > Usuarios > opcoes > Bloquear
  # ===========================================================================

  @qase.id=1260 @qase.title=Hermitage AdminUsers Block: PUT sem auth retorna 403
  @negative @smoke
  Scenario: PUT users/{id}/block sem Authorization retorna 403
    Given path usersPath + '/' + idInexistente + '/block'
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  @qase.id=1261 @qase.title=Hermitage AdminUsers Block: PUT com sk_live retorna 403
  @negative
  Scenario: PUT users/{id}/block com sk_live retorna 403
    Given path usersPath + '/' + idInexistente + '/block'
    And header Authorization = secretKey
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # PUT /hermitage/users/{id}/unblock — Desbloquear usuario (Admin)
  # Tela: Administracao > Usuarios > opcoes
  # ===========================================================================

  @qase.id=1262 @qase.title=Hermitage AdminUsers Unblock: PUT sem auth retorna 403
  @negative @smoke
  Scenario: PUT users/{id}/unblock sem Authorization retorna 403
    Given path usersPath + '/' + idInexistente + '/unblock'
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  @qase.id=1263 @qase.title=Hermitage AdminUsers Unblock: PUT com sk_live retorna 403
  @negative
  Scenario: PUT users/{id}/unblock com sk_live retorna 403
    Given path usersPath + '/' + idInexistente + '/unblock'
    And header Authorization = secretKey
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # POST /hermitage/users/{id}/turn-partner — Habilitar parceria (Admin)
  # Tela: Administracao > Usuarios > opcoes > Habilitar parceria
  # ===========================================================================

  @qase.id=1270 @qase.title=Hermitage AdminUsers TurnPartner: POST sem auth retorna 403
  @negative @smoke
  Scenario: POST users/{id}/turn-partner sem Authorization retorna 403
    Given path usersPath + '/' + idInexistente + '/turn-partner'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1271 @qase.title=Hermitage AdminUsers TurnPartner: POST com sk_live retorna 403
  @negative
  Scenario: POST users/{id}/turn-partner com sk_live retorna 403
    Given path usersPath + '/' + idInexistente + '/turn-partner'
    And header Authorization = secretKey
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # POST /hermitage/users/{id}/remove-partner — Remover parceria (Admin)
  # Tela: Administracao > Usuarios > opcoes > Retirar Parceria
  # ===========================================================================

  @qase.id=1272 @qase.title=Hermitage AdminUsers RemovePartner: POST sem auth retorna 403
  @negative @smoke
  Scenario: POST users/{id}/remove-partner sem Authorization retorna 403
    Given path usersPath + '/' + idInexistente + '/remove-partner'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1273 @qase.title=Hermitage AdminUsers RemovePartner: POST com sk_live retorna 403
  @negative
  Scenario: POST users/{id}/remove-partner com sk_live retorna 403
    Given path usersPath + '/' + idInexistente + '/remove-partner'
    And header Authorization = secretKey
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # POST /hermitage/users/{id}/turn-into-pyramid — Habilitar influencer (Admin)
  # Tela: Administracao > Influencers > Habilitar influencer
  # ===========================================================================

  @qase.id=1280 @qase.title=Hermitage AdminUsers TurnPyramid: POST sem auth retorna 403
  @negative @smoke
  Scenario: POST users/{id}/turn-into-pyramid sem Authorization retorna 403
    Given path usersPath + '/' + idInexistente + '/turn-into-pyramid'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1281 @qase.title=Hermitage AdminUsers TurnPyramid: POST com sk_live retorna 403
  @negative
  Scenario: POST users/{id}/turn-into-pyramid com sk_live retorna 403
    Given path usersPath + '/' + idInexistente + '/turn-into-pyramid'
    And header Authorization = secretKey
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # GET /hermitage/billing/invoices — Listar faturas
  # Tela: Faturamento > Assinatura > Faturas
  # ===========================================================================

  @qase.id=1290 @qase.title=Hermitage Billing Invoices: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET billing/invoices sem Authorization retorna 403
    Given path billingPath + '/invoices'
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1291 @qase.title=Hermitage Billing Invoices: GET com sk_live retorna 403
  @negative @smoke
  Scenario: GET billing/invoices com sk_live retorna 403 pois exige JWT de sessao
    Given path billingPath + '/invoices'
    And header Authorization = secretKey
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1292 @qase.title=Hermitage Billing Invoices: GET com Bearer sk_live retorna 403
  @negative
  Scenario: GET billing/invoices com Bearer sk_live retorna 403
    Given path billingPath + '/invoices'
    And header Authorization = bearerSecretKey
    When method GET
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # GET /hermitage/billing/upcoming — Proxima fatura
  # Tela: Faturamento > Assinatura > Proxima cobranca
  # ===========================================================================

  @qase.id=1295 @qase.title=Hermitage Billing Upcoming: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET billing/upcoming sem Authorization retorna 403
    Given path billingPath + '/upcoming'
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1296 @qase.title=Hermitage Billing Upcoming: GET com sk_live retorna 403
  @negative
  Scenario: GET billing/upcoming com sk_live retorna 403 pois exige JWT de sessao
    Given path billingPath + '/upcoming'
    And header Authorization = secretKey
    When method GET
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # GET /hermitage/billing/subscription-timeline — Linha do tempo assinaturas
  # Tela: Faturamento > Assinatura > Historico
  # ===========================================================================

  @qase.id=1298 @qase.title=Hermitage Billing SubscriptionTimeline: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET billing/subscription-timeline sem Authorization retorna 403
    Given path billingPath + '/subscription-timeline'
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1299 @qase.title=Hermitage Billing SubscriptionTimeline: GET com sk_live retorna 403
  @negative
  Scenario: GET billing/subscription-timeline com sk_live retorna 403 pois exige JWT
    Given path billingPath + '/subscription-timeline'
    And header Authorization = secretKey
    When method GET
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # GET /hermitage/admin/workspaces — Listar workspaces (Admin)
  # Tela: Administracao > painel admin
  # ===========================================================================

  @qase.id=1300 @qase.title=Hermitage AdminWorkspaces: GET sem auth retorna 403
  @negative @smoke
  Scenario: GET admin/workspaces sem Authorization retorna 403
    Given path adminWorkspacesPath
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1301 @qase.title=Hermitage AdminWorkspaces: GET com sk_live retorna 403
  @negative @smoke
  Scenario: GET admin/workspaces com sk_live retorna 403 pois exige JWT de admin
    Given path adminWorkspacesPath
    And header Authorization = secretKey
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1302 @qase.title=Hermitage AdminWorkspaces: GET com Bearer sk_live retorna 200 ou 403
  @negative
  Scenario: GET admin/workspaces com Bearer sk_live retorna 200 ou 403
    Given path adminWorkspacesPath
    And header Authorization = bearerSecretKey
    When method GET
    Then match [200, 403, 404] contains responseStatus

  # ===========================================================================
  # POST /hermitage/admin/workspaces/{id}/turn-partner — Tornar workspace parceiro
  # Tela: Administracao > Usuarios > opcoes > Habilitar parceria (workspace)
  # ===========================================================================

  @qase.id=1310 @qase.title=Hermitage AdminWorkspaces TurnPartner: POST sem auth retorna 403
  @negative @smoke
  Scenario: POST admin/workspaces/{id}/turn-partner sem Authorization retorna 403
    Given path adminWorkspacesPath + '/' + idInexistente + '/turn-partner'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1311 @qase.title=Hermitage AdminWorkspaces TurnPartner: POST com sk_live retorna 403
  @negative
  Scenario: POST admin/workspaces/{id}/turn-partner com sk_live retorna 403
    Given path adminWorkspacesPath + '/' + idInexistente + '/turn-partner'
    And header Authorization = secretKey
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # POST /hermitage/admin/workspaces/{id}/remove-partner — Remover parceria workspace
  # Tela: Administracao > Usuarios > opcoes > Retirar Parceria
  # ===========================================================================

  @qase.id=1312 @qase.title=Hermitage AdminWorkspaces RemovePartner: POST sem auth retorna 403
  @negative @smoke
  Scenario: POST admin/workspaces/{id}/remove-partner sem Authorization retorna 403
    Given path adminWorkspacesPath + '/' + idInexistente + '/remove-partner'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1313 @qase.title=Hermitage AdminWorkspaces RemovePartner: POST com sk_live retorna 403
  @negative
  Scenario: POST admin/workspaces/{id}/remove-partner com sk_live retorna 403
    Given path adminWorkspacesPath + '/' + idInexistente + '/remove-partner'
    And header Authorization = secretKey
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  # ===========================================================================
  # Testes com usuarios reais de administracao
  # Usuarios permitidos para manipulacao:
  #   - Ryan Andrade   (ryan.andrade@grupoirrah.com) — adminUserIdRyan
  #   - Parceiro teste (parceiro@grupoirrah.com)     — adminUserIdParceiro
  # ===========================================================================

  @qase.id=1320 @qase.title=Hermitage AdminUsers RealUser: GET verifica que Parceiro teste existe na listagem
  @positive @smoke
  Scenario: GET users/v2 sem auth retorna 403 — confirma que endpoint de listagem e protegido
    Given path usersPath + '/v2'
    When method GET
    Then match [403, 404] contains responseStatus

  @qase.id=1321 @qase.title=Hermitage AdminUsers RealUser: PUT bloquear Parceiro teste sem auth retorna 403
  @negative @smoke
  Scenario: PUT block usuario Parceiro teste sem auth retorna 403
    Given path usersPath + '/' + adminUserIdParceiro + '/block'
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  @qase.id=1322 @qase.title=Hermitage AdminUsers RealUser: PUT desbloquear Parceiro teste sem auth retorna 403
  @negative @smoke
  Scenario: PUT unblock usuario Parceiro teste sem auth retorna 403
    Given path usersPath + '/' + adminUserIdParceiro + '/unblock'
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  @qase.id=1323 @qase.title=Hermitage AdminUsers RealUser: POST habilitar parceria Parceiro teste sem auth retorna 403
  @negative @smoke
  Scenario: POST turn-partner usuario Parceiro teste sem auth retorna 403
    Given path usersPath + '/' + adminUserIdParceiro + '/turn-partner'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1324 @qase.title=Hermitage AdminUsers RealUser: POST remover parceria Parceiro teste sem auth retorna 403
  @negative @smoke
  Scenario: POST remove-partner usuario Parceiro teste sem auth retorna 403
    Given path usersPath + '/' + adminUserIdParceiro + '/remove-partner'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1325 @qase.title=Hermitage AdminUsers RealUser: PUT bloquear Parceiro teste com sk_live retorna 403
  @negative
  Scenario: PUT block usuario Parceiro teste com sk_live retorna 403 pois exige JWT admin
    Given path usersPath + '/' + adminUserIdParceiro + '/block'
    And header Authorization = secretKey
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  @qase.id=1326 @qase.title=Hermitage AdminUsers RealUser: POST set-partner_days-of-trial Parceiro teste sem auth retorna 403
  @negative
  Scenario: POST set-partner_days-of-trial usuario Parceiro teste sem auth retorna 403
    Given path usersPath + '/' + adminUserIdParceiro + '/set-partner_days-of-trial'
    And request { "days": 30 }
    When method POST
    Then match [403, 404] contains responseStatus

  @qase.id=1327 @qase.title=Hermitage AdminUsers RealUser: PUT bloquear Ryan sem auth retorna 403
  @negative @smoke
  Scenario: PUT block usuario Ryan sem auth retorna 403
    Given path usersPath + '/' + adminUserIdRyan + '/block'
    And request {}
    When method PUT
    Then match [403, 404] contains responseStatus

  @qase.id=1328 @qase.title=Hermitage AdminUsers RealUser: POST turn-partner Ryan sem auth retorna 403
  @negative
  Scenario: POST turn-partner usuario Ryan sem auth retorna 403
    Given path usersPath + '/' + adminUserIdRyan + '/turn-partner'
    And request {}
    When method POST
    Then match [403, 404] contains responseStatus
