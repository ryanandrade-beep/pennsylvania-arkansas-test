@hermitage @regression
Feature: Hermitage — Auditoria, Usuarios e Faturamento

  Testa os endpoints do servico Hermitage (identidade, auditoria e faturamento)
  via API HubMessage.

  IMPORTANTE: Os endpoints do Hermitage exigem autenticacao JWT de sessao de
  usuario (cookie ou Bearer com token gerado via POST /hermitage/users/signin).
  A secret key (sk_live_*) retorna 403 nesses endpoints pois e token de
  integracao, nao de sessao de usuario.

  Endpoints cobertos:
    GET  /hermitage/audit-events        — listar eventos de auditoria
    GET  /hermitage/audit-events/actions — listar acoes de auditoria
    GET  /hermitage/users/get-user      — obter usuario atual
    PUT  /hermitage/users/update        — atualizar dados do usuario
    PUT  /hermitage/person-bills        — atualizar dados de faturamento

  Background:
    * url baseUrl
    * def hermitageBase = '/hermitage'
    * def auditPath = hermitageBase + '/audit-events'
    * def auditActionsPath = hermitageBase + '/audit-events/actions'
    * def getUserPath = hermitageBase + '/users/get-user'
    * def updateUserPath = hermitageBase + '/users/update'
    * def personBillsPath = hermitageBase + '/person-bills'

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
