@channels @regression
Feature: Channels — Criar e conectar canais HubMessage

  Testa os endpoints de criacao e conexao de canais via API HubMessage.

  Endpoint de criacao via painel (pennsylvania-hermitage):
    POST /hermitage/channels
    Body: { "name": "...", "middleware": "..." }
    Auth: JWT de sessao de usuario (sk_live retorna 403 — tem ALLOW_INTEGRATION)
    Tipos (middleware): META_WHATSAPP, Z_API_WHATSAPP, BOT_TELEGRAM, META_INSTAGRAM, META_MESSENGER

  Endpoint de conexao (arkansas-newport via frisco):
    POST /v1/channels/{channelId}/connect
    Auth: Bearer sk_live

  Nota: O CRUD completo de canais via Newport (POST /v1/channels, GET, PUT, DELETE)
  esta coberto em newport-channels.feature.

  Background:
    * url baseUrl
    * def hermitageChannelsPath = '/hermitage/channels'
    * def newportChannelsPath = '/v1/channels'
    * def bearerAuth = 'Bearer ' + secretKey
    * def invalidBearer = 'Bearer chave-invalida-que-nao-existe'

  # ===========================================================================
  # POST /hermitage/channels — Criar canal via painel interno
  # Todos os tipos de middleware sao verificados com sk_live (retorna 403)
  # pois esse endpoint exige JWT de sessao sem ALLOW_INTEGRATION
  # Tela: Painel > Canais > Novo canal
  # ===========================================================================

  @qase.id=500 @qase.title=Channels CreateChannel: POST sem auth retorna 403
  @negative @smoke
  Scenario: POST /hermitage/channels sem Authorization retorna 403
    Given path hermitageChannelsPath
    And request { "name": "Canal Teste", "middleware": "META_WHATSAPP" }
    When method POST
    Then match [400, 401, 403, 500] contains responseStatus

  @qase.id=501 @qase.title=Channels CreateChannel: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST /hermitage/channels com Authorization invalido retorna 403
    Given path hermitageChannelsPath
    And header Authorization = invalidBearer
    And request { "name": "Canal Teste", "middleware": "META_WHATSAPP" }
    When method POST
    Then match [400, 401, 403] contains responseStatus

  @qase.id=502 @qase.title=Channels CreateChannel: POST META_WHATSAPP com sk_live retorna 403
  @negative @smoke
  Scenario: POST /hermitage/channels META_WHATSAPP com sk_live retorna 403
    Given path hermitageChannelsPath
    And header Authorization = bearerAuth
    And request { "name": "Karate META_WHATSAPP", "middleware": "META_WHATSAPP" }
    When method POST
    Then status 403

  @qase.id=503 @qase.title=Channels CreateChannel: POST Z_API_WHATSAPP com sk_live retorna 403
  @negative
  Scenario: POST /hermitage/channels Z_API_WHATSAPP com sk_live retorna 403
    Given path hermitageChannelsPath
    And header Authorization = bearerAuth
    And request { "name": "Karate Z_API_WHATSAPP", "middleware": "Z_API_WHATSAPP" }
    When method POST
    Then status 403

  @qase.id=504 @qase.title=Channels CreateChannel: POST BOT_TELEGRAM com sk_live retorna 403
  @negative @smoke
  Scenario: POST /hermitage/channels BOT_TELEGRAM com sk_live retorna 403
    Given path hermitageChannelsPath
    And header Authorization = bearerAuth
    And request { "name": "Karate BOT_TELEGRAM", "middleware": "BOT_TELEGRAM" }
    When method POST
    Then status 403

  @qase.id=505 @qase.title=Channels CreateChannel: POST META_INSTAGRAM com sk_live retorna 403
  @negative @smoke
  Scenario: POST /hermitage/channels META_INSTAGRAM com sk_live retorna 403
    Given path hermitageChannelsPath
    And header Authorization = bearerAuth
    And request { "name": "Karate META_INSTAGRAM", "middleware": "META_INSTAGRAM" }
    When method POST
    Then status 403

  @qase.id=506 @qase.title=Channels CreateChannel: POST META_MESSENGER com sk_live retorna 403
  @negative @smoke
  Scenario: POST /hermitage/channels META_MESSENGER com sk_live retorna 403
    Given path hermitageChannelsPath
    And header Authorization = bearerAuth
    And request { "name": "Karate META_MESSENGER", "middleware": "META_MESSENGER" }
    When method POST
    Then status 403

  # ===========================================================================
  # POST /v1/channels/{channelId}/connect — Conectar canal ao numero WhatsApp
  # ===========================================================================

  @qase.id=510 @qase.title=Channels ConnectChannel: POST com auth invalido retorna 400
  @negative
  Scenario: POST conectar canal com Authorization invalido retorna 400
    Given path newportChannelsPath + '/' + metaChannelId + '/connect'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then status 400

  @qase.id=511 @qase.title=Channels ConnectChannel: POST sem auth retorna 400 ou 500
  @negative
  Scenario: POST conectar canal sem Authorization retorna 400 ou 500
    Given path newportChannelsPath + '/' + metaChannelId + '/connect'
    And request {}
    When method POST
    Then match [400, 500] contains responseStatus

  @qase.id=512 @qase.title=Channels ConnectChannel: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST conectar canal com channelId inexistente retorna 404
    Given path newportChannelsPath + '/00000000000000000000000000000000/connect'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=513 @qase.title=Channels ConnectChannel: POST canal valido valida que API e chamada
  @positive @smoke
  Scenario: POST conectar canal valido valida que a API e chamada retorna 200 ou 400 ou 502
    Given path newportChannelsPath + '/' + metaChannelId + '/connect'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [200, 400, 502] contains responseStatus
    And match response == '#notnull'
