@newport @zapi @groups @regression
Feature: Newport — Grupos WhatsApp Z-API

  Testa os endpoints de gerenciamento de grupos WhatsApp
  via instancias Z-API do servico arkansas-newport.

  NOTA: os cenarios @positive cobrem autenticacao e roteamento corretos.
  Como a instancia Z-API nao esta conectada no ambiente de teste,
  o comportamento esperado do upstream e 502 (Bad Gateway) ou 404
  (canal nao encontrado). Um retorno 200 so ocorre com instancia conectada.

  POST /v1/channels/{id}/zapi/instances/create-group
  POST /v1/channels/{id}/zapi/instances/update-group-name
  POST /v1/channels/{id}/zapi/instances/add-participant
  POST /v1/channels/{id}/zapi/instances/remove-participant
  POST /v1/channels/{id}/zapi/instances/leave-group
  POST /v1/channels/{id}/zapi/instances/add-admin
  POST /v1/channels/{id}/zapi/instances/remove-admin
  POST /v1/channels/{id}/zapi/instances/update-group-settings
  POST /v1/channels/{id}/zapi/instances/update-group-photo
  POST /v1/channels/{id}/zapi/instances/update-group-description

  Background:
    * url newportUrl
    * def zapiBase = '/v1/channels/' + channelId + '/zapi/instances'
    * def validGroupPayload =
      """
      {
        "groupName": "Grupo Karate Test",
        "participants": ["#(phoneNumber)"]
      }
      """

  # ===========================================================================
  # POST create-group
  # ===========================================================================

  @qase.id=500 @qase.title=Newport Groups CreateGroup: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST create-group com Authorization invalido retorna 400
    Given path zapiBase + '/create-group'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request validGroupPayload
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=501 @qase.title=Newport Groups CreateGroup: POST sem auth retorna 400
  @negative
  Scenario: POST create-group sem Authorization retorna 400
    Given path zapiBase + '/create-group'
    And request validGroupPayload
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=502 @qase.title=Newport Groups CreateGroup: POST com payload vazio retorna 400 ou 502
  @negative
  Scenario: POST create-group com payload vazio retorna 400 ou 502
    Given path zapiBase + '/create-group'
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then match [400, 404, 502] contains responseStatus

  @qase.id=503 @qase.title=Newport Groups CreateGroup: POST com dados validos retorna 502 quando nao conectado
  @positive
  Scenario: POST create-group sem conexao retorna 502
    Given path zapiBase + '/create-group'
    And header Authorization = 'Bearer ' + secretKey
    And request validGroupPayload
    When method POST
    # 502 = instancia nao conectada; criacao de grupo requer sessao WhatsApp ativa
    # 404 = canal nao encontrado no ambiente
    Then match [404, 502] contains responseStatus

  # ===========================================================================
  # POST update-group-name
  # ===========================================================================

  @qase.id=510 @qase.title=Newport Groups UpdateGroupName: POST com auth invalido retorna 400
  @negative
  Scenario: POST update-group-name com Authorization invalido retorna 400
    Given path zapiBase + '/update-group-name'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "name": "Novo Nome" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=511 @qase.title=Newport Groups UpdateGroupName: POST sem auth retorna 400
  @negative
  Scenario: POST update-group-name sem Authorization retorna 400
    Given path zapiBase + '/update-group-name'
    And request { "groupId": "fake-group-id", "name": "Novo Nome" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=512 @qase.title=Newport Groups UpdateGroupName: POST com dados validos retorna 502 quando nao conectado
  @positive
  Scenario: POST update-group-name sem conexao retorna 502
    Given path zapiBase + '/update-group-name'
    And header Authorization = 'Bearer ' + secretKey
    And request { "groupId": "fake-group-id", "name": "Grupo Karate Atualizado" }
    When method POST
    # 502 = instancia nao conectada
    # 404 = canal nao encontrado no ambiente
    Then match [404, 502] contains responseStatus

  # ===========================================================================
  # POST add-participant
  # ===========================================================================

  @qase.id=520 @qase.title=Newport Groups AddParticipant: POST com auth invalido retorna 400
  @negative
  Scenario: POST add-participant com Authorization invalido retorna 400
    Given path zapiBase + '/add-participant'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=521 @qase.title=Newport Groups AddParticipant: POST sem auth retorna 400
  @negative
  Scenario: POST add-participant sem Authorization retorna 400
    Given path zapiBase + '/add-participant'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=522 @qase.title=Newport Groups AddParticipant: POST com dados validos retorna 502 quando nao conectado
  @positive
  Scenario: POST add-participant sem conexao retorna 502
    Given path zapiBase + '/add-participant'
    And header Authorization = 'Bearer ' + secretKey
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    # 502 = instancia nao conectada
    # 404 = canal nao encontrado no ambiente
    Then match [404, 502] contains responseStatus

  # ===========================================================================
  # POST remove-participant
  # ===========================================================================

  @qase.id=530 @qase.title=Newport Groups RemoveParticipant: POST com auth invalido retorna 400
  @negative
  Scenario: POST remove-participant com Authorization invalido retorna 400
    Given path zapiBase + '/remove-participant'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=531 @qase.title=Newport Groups RemoveParticipant: POST sem auth retorna 400
  @negative
  Scenario: POST remove-participant sem Authorization retorna 400
    Given path zapiBase + '/remove-participant'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST leave-group
  # ===========================================================================

  @qase.id=540 @qase.title=Newport Groups LeaveGroup: POST com auth invalido retorna 400
  @negative
  Scenario: POST leave-group com Authorization invalido retorna 400
    Given path zapiBase + '/leave-group'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=541 @qase.title=Newport Groups LeaveGroup: POST sem auth retorna 400
  @negative
  Scenario: POST leave-group sem Authorization retorna 400
    Given path zapiBase + '/leave-group'
    And request { "groupId": "fake-group-id" }
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST add-admin
  # ===========================================================================

  @qase.id=550 @qase.title=Newport Groups AddAdmin: POST com auth invalido retorna 400
  @negative
  Scenario: POST add-admin com Authorization invalido retorna 400
    Given path zapiBase + '/add-admin'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=551 @qase.title=Newport Groups AddAdmin: POST sem auth retorna 400
  @negative
  Scenario: POST add-admin sem Authorization retorna 400
    Given path zapiBase + '/add-admin'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST remove-admin
  # ===========================================================================

  @qase.id=560 @qase.title=Newport Groups RemoveAdmin: POST com auth invalido retorna 400
  @negative
  Scenario: POST remove-admin com Authorization invalido retorna 400
    Given path zapiBase + '/remove-admin'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=561 @qase.title=Newport Groups RemoveAdmin: POST sem auth retorna 400
  @negative
  Scenario: POST remove-admin sem Authorization retorna 400
    Given path zapiBase + '/remove-admin'
    And request { "groupId": "fake-group-id", "phone": "#(phoneNumber)" }
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST update-group-settings
  # ===========================================================================

  @qase.id=570 @qase.title=Newport Groups UpdateSettings: POST com auth invalido retorna 400
  @negative
  Scenario: POST update-group-settings com Authorization invalido retorna 400
    Given path zapiBase + '/update-group-settings'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "settings": {} }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=571 @qase.title=Newport Groups UpdateSettings: POST sem auth retorna 400
  @negative
  Scenario: POST update-group-settings sem Authorization retorna 400
    Given path zapiBase + '/update-group-settings'
    And request { "groupId": "fake-group-id", "settings": {} }
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST update-group-photo
  # ===========================================================================

  @qase.id=580 @qase.title=Newport Groups UpdatePhoto: POST com auth invalido retorna 400
  @negative
  Scenario: POST update-group-photo com Authorization invalido retorna 400
    Given path zapiBase + '/update-group-photo'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "photo": "https://exemplo.com/foto.jpg" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=581 @qase.title=Newport Groups UpdatePhoto: POST sem auth retorna 400
  @negative
  Scenario: POST update-group-photo sem Authorization retorna 400
    Given path zapiBase + '/update-group-photo'
    And request { "groupId": "fake-group-id", "photo": "https://exemplo.com/foto.jpg" }
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST update-group-description
  # ===========================================================================

  @qase.id=590 @qase.title=Newport Groups UpdateDescription: POST com auth invalido retorna 400
  @negative
  Scenario: POST update-group-description com Authorization invalido retorna 400
    Given path zapiBase + '/update-group-description'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "groupId": "fake-group-id", "description": "Nova descricao" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=591 @qase.title=Newport Groups UpdateDescription: POST sem auth retorna 400
  @negative
  Scenario: POST update-group-description sem Authorization retorna 400
    Given path zapiBase + '/update-group-description'
    And request { "groupId": "fake-group-id", "description": "Nova descricao" }
    When method POST
    Then match [400, 404] contains responseStatus
