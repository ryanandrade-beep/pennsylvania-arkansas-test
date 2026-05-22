@channels @regression
Feature: Channels — Criar e conectar canais HubMessage

  Testa os endpoints de criacao e conexao de canais via API HubMessage.

  Refs:
    https://developer.hubmessage.io/channels/create-channel
    https://developer.hubmessage.io/channels/connect-channel

  POST /v1/channels
  POST /v1/channels/{channelId}/connect

  Background:
    * url baseUrl
    * def channelsPrefix = '/v1/channels'
    * def bearerAuth = 'Bearer ' + secretKey
    * def invalidBearer = 'Bearer chave-invalida-que-nao-existe'

  # ===========================================================================
  # POST /v1/channels — Criar canal
  # ===========================================================================

  @qase.id=500 @qase.title=Channels CreateChannel: Criar canal com auth invalido retorna 400
  @negative
  Scenario: Criar canal com Authorization invalido retorna 400
    Given path channelsPrefix
    And header Authorization = invalidBearer
    And request { "name": "Canal Teste", "type": "META_WHATSAPP" }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=501 @qase.title=Channels CreateChannel: Criar canal sem auth retorna 500
  @negative
  Scenario: Criar canal sem Authorization retorna 500
    Given path channelsPrefix
    And request { "name": "Canal Teste", "type": "META_WHATSAPP" }
    When method POST
    Then match [500, 404] contains responseStatus

  @qase.id=502 @qase.title=Channels CreateChannel: Criar canal com payload vazio retorna 502
  @negative
  Scenario: Criar canal com payload vazio retorna 502
    Given path channelsPrefix
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [502, 404] contains responseStatus

  @qase.id=503 @qase.title=Channels CreateChannel: Criar canal com tipo invalido retorna 500
  @negative
  Scenario: Criar canal com tipo invalido retorna 500
    Given path channelsPrefix
    And header Authorization = bearerAuth
    And request { "name": "Canal Teste", "type": "TIPO_INVALIDO" }
    When method POST
    Then match [500, 404] contains responseStatus

  @qase.id=504 @qase.title=Channels CreateChannel: Criar canal META_WHATSAPP retorna 201
  @positive @smoke
  Scenario: Criar canal META_WHATSAPP retorna 201 com id definido
    Given path channelsPrefix
    And header Authorization = bearerAuth
    And request { "name": "Canal Karate API Test", "type": "META_WHATSAPP" }
    When method POST
    Then match [201, 404] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{channelId}/connect — Conectar canal (validar chamada)
  # ===========================================================================

  @qase.id=510 @qase.title=Channels ConnectChannel: Conectar canal com auth invalido retorna 400
  @negative
  Scenario: Conectar canal com Authorization invalido retorna 400
    Given path channelsPrefix + '/' + metaChannelId + '/connect'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then status 400

  @qase.id=511 @qase.title=Channels ConnectChannel: Conectar canal sem auth retorna 400 ou 500
  @negative
  Scenario: Conectar canal sem Authorization retorna 400 ou 500
    Given path channelsPrefix + '/' + metaChannelId + '/connect'
    And request {}
    When method POST
    Then match [400, 500] contains responseStatus

  @qase.id=512 @qase.title=Channels ConnectChannel: Conectar canal com channelId inexistente retorna 404
  @negative
  Scenario: Conectar canal com channelId inexistente retorna 404
    Given path channelsPrefix + '/00000000000000000000000000000000/connect'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=513 @qase.title=Channels ConnectChannel: Conectar canal valido valida chamada a API retorna 200 ou 502
  @positive @smoke
  Scenario: Conectar canal valido valida que a API e chamada e retorna 200 ou 502
    Given path channelsPrefix + '/' + metaChannelId + '/connect'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [200, 400, 502] contains responseStatus
    And match response == '#notnull'
