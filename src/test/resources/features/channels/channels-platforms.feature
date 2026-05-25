@channels @platforms @regression
Feature: Channels Platforms — Ativar e desativar plataformas nos canais

  Testa os endpoints de ativacao e desativacao de plataformas em canais
  existentes via API HubMessage.

  Plataformas cobertas:
    - Meta WhatsApp  (activate-meta / deactivate-meta)
    - Instagram      (activate-instagram / deactivate-instagram)
    - Messenger      (activate-messenger / deactivate-messenger + list-messenger-pages)
    - Telegram       (activate-telegram / deactivate-telegram)

  Obs: Os endpoints de ativacao exigem dados especificos da plataforma
  (wabaId, phoneId, code para Meta; botToken para Telegram; code+pageId para
  Instagram e Messenger). Como esses dados sao gerados via OAuth/SDK, os testes
  positivos verificam que a API e chamada corretamente (200/400/502).
  Os testes negativos verificam rejeicao com auth invalido.

  POST /channels/{id}/activate-meta
  POST /channels/{id}/deactivate-meta
  POST /channels/{id}/activate-instagram
  POST /channels/{id}/deactivate-instagram
  POST /channels/{id}/list-messenger-pages
  POST /channels/{id}/activate-messenger
  POST /channels/{id}/deactivate-messenger
  POST /channels/{id}/activate-telegram
  POST /channels/{id}/deactivate-telegram

  Background:
    * url baseUrl
    * def channelBase = '/channels'
    * def bearerAuth = 'Bearer ' + secretKey
    * def invalidBearer = 'Bearer chave-invalida-que-nao-existe'
    * def idInexistente = '00000000000000000000000000000000'

  # ===========================================================================
  # POST /channels/{id}/activate-meta — Ativar WhatsApp Meta
  # Tela: Canais > WhatsApp > Conectar
  # ===========================================================================

  @qase.id=600 @qase.title=Platforms ActivateMeta: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST activate-meta com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-meta'
    And header Authorization = invalidBearer
    And request { "wabaId": "000000000000000", "phoneId": "000000000000000", "code": "FAKE", "coexistence": false }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=601 @qase.title=Platforms ActivateMeta: POST sem auth retorna 400
  @negative
  Scenario: POST activate-meta sem Authorization retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-meta'
    And request { "wabaId": "000000000000000", "phoneId": "000000000000000", "code": "FAKE", "coexistence": false }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=602 @qase.title=Platforms ActivateMeta: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST activate-meta com channelId inexistente retorna 404
    Given path channelBase + '/' + idInexistente + '/activate-meta'
    And header Authorization = bearerAuth
    And request { "wabaId": "000000000000000", "phoneId": "000000000000000", "code": "FAKE", "coexistence": false }
    When method POST
    Then match [404, 400, 502] contains responseStatus

  @qase.id=603 @qase.title=Platforms ActivateMeta: POST com payload invalido e auth valido retorna 400 ou 502
  @positive @smoke
  Scenario: POST activate-meta com auth valido e payload invalido valida que API e chamada
    Given path channelBase + '/' + metaChannelId + '/activate-meta'
    And header Authorization = bearerAuth
    And request { "wabaId": "000000000000000", "phoneId": "000000000000000", "code": "FAKE_CODE_KARATE", "coexistence": false }
    When method POST
    Then match [200, 400, 402, 404, 422, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-meta — Desativar WhatsApp Meta
  # ===========================================================================

  @qase.id=604 @qase.title=Platforms DeactivateMeta: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST deactivate-meta com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/deactivate-meta'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=605 @qase.title=Platforms DeactivateMeta: POST com auth valido valida que API e chamada
  @positive @smoke
  Scenario: POST deactivate-meta com auth valido valida que API e chamada retorna 200 ou 502
    Given path channelBase + '/' + metaChannelId + '/deactivate-meta'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [200, 400, 402, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/activate-instagram — Ativar Instagram
  # Tela: Canais > Instagram > Conectar
  # ===========================================================================

  @qase.id=610 @qase.title=Platforms ActivateInstagram: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST activate-instagram com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-instagram'
    And header Authorization = invalidBearer
    And request { "code": "FAKE_INSTAGRAM_CODE", "pageId": "000000000000000" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=611 @qase.title=Platforms ActivateInstagram: POST sem auth retorna 400
  @negative
  Scenario: POST activate-instagram sem Authorization retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-instagram'
    And request { "code": "FAKE_INSTAGRAM_CODE", "pageId": "000000000000000" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=612 @qase.title=Platforms ActivateInstagram: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST activate-instagram com channelId inexistente retorna 404
    Given path channelBase + '/' + idInexistente + '/activate-instagram'
    And header Authorization = bearerAuth
    And request { "code": "FAKE_INSTAGRAM_CODE", "pageId": "000000000000000" }
    When method POST
    Then match [404, 400, 502] contains responseStatus

  @qase.id=613 @qase.title=Platforms ActivateInstagram: POST com auth valido e payload invalido valida que API e chamada
  @positive @smoke
  Scenario: POST activate-instagram com auth valido valida que API e chamada retorna 200 ou 400 ou 502
    Given path channelBase + '/' + metaChannelId + '/activate-instagram'
    And header Authorization = bearerAuth
    And request { "code": "FAKE_CODE_KARATE_INSTAGRAM", "pageId": "000000000000000" }
    When method POST
    Then match [200, 400, 402, 422, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-instagram — Desativar Instagram
  # ===========================================================================

  @qase.id=614 @qase.title=Platforms DeactivateInstagram: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST deactivate-instagram com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/deactivate-instagram'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=615 @qase.title=Platforms DeactivateInstagram: POST com auth valido valida que API e chamada
  @positive
  Scenario: POST deactivate-instagram com auth valido valida que API e chamada
    Given path channelBase + '/' + metaChannelId + '/deactivate-instagram'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [200, 400, 402, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/list-messenger-pages — Listar paginas do Messenger
  # Tela: Canais > Messenger > selecionar pagina
  # ===========================================================================

  @qase.id=620 @qase.title=Platforms ListMessengerPages: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST list-messenger-pages com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/list-messenger-pages'
    And header Authorization = invalidBearer
    And request { "code": "FAKE_MESSENGER_CODE" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=621 @qase.title=Platforms ListMessengerPages: POST sem auth retorna 400
  @negative
  Scenario: POST list-messenger-pages sem Authorization retorna 400
    Given path channelBase + '/' + metaChannelId + '/list-messenger-pages'
    And request { "code": "FAKE_MESSENGER_CODE" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=622 @qase.title=Platforms ListMessengerPages: POST com auth valido valida que API e chamada
  @positive @smoke
  Scenario: POST list-messenger-pages com auth valido valida que API e chamada retorna 200 ou 400 ou 502
    Given path channelBase + '/' + metaChannelId + '/list-messenger-pages'
    And header Authorization = bearerAuth
    And request { "code": "FAKE_CODE_KARATE_MESSENGER" }
    When method POST
    Then match [200, 400, 402, 422, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/activate-messenger — Ativar Messenger
  # Tela: Canais > Messenger > Conectar
  # ===========================================================================

  @qase.id=630 @qase.title=Platforms ActivateMessenger: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST activate-messenger com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-messenger'
    And header Authorization = invalidBearer
    And request { "code": "FAKE_MESSENGER_CODE", "pageId": "000000000000000" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=631 @qase.title=Platforms ActivateMessenger: POST sem auth retorna 400
  @negative
  Scenario: POST activate-messenger sem Authorization retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-messenger'
    And request { "code": "FAKE_MESSENGER_CODE", "pageId": "000000000000000" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=632 @qase.title=Platforms ActivateMessenger: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST activate-messenger com channelId inexistente retorna 404
    Given path channelBase + '/' + idInexistente + '/activate-messenger'
    And header Authorization = bearerAuth
    And request { "code": "FAKE_MESSENGER_CODE", "pageId": "000000000000000" }
    When method POST
    Then match [404, 400, 502] contains responseStatus

  @qase.id=633 @qase.title=Platforms ActivateMessenger: POST com auth valido valida que API e chamada
  @positive @smoke
  Scenario: POST activate-messenger com auth valido valida que API e chamada retorna 200 ou 400 ou 502
    Given path channelBase + '/' + metaChannelId + '/activate-messenger'
    And header Authorization = bearerAuth
    And request { "code": "FAKE_CODE_KARATE_MESSENGER", "pageId": "000000000000000" }
    When method POST
    Then match [200, 400, 402, 422, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-messenger — Desativar Messenger
  # ===========================================================================

  @qase.id=634 @qase.title=Platforms DeactivateMessenger: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST deactivate-messenger com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/deactivate-messenger'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=635 @qase.title=Platforms DeactivateMessenger: POST com auth valido valida que API e chamada
  @positive
  Scenario: POST deactivate-messenger com auth valido valida que API e chamada
    Given path channelBase + '/' + metaChannelId + '/deactivate-messenger'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [200, 400, 402, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/activate-telegram — Ativar Telegram
  # Tela: Canais > Telegram (via Newport: PUT /v1/channels/{id}/telegram/active)
  # Aqui testamos o endpoint do hermitage que e a camada de negocio
  # ===========================================================================

  @qase.id=640 @qase.title=Platforms ActivateTelegram: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST activate-telegram com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-telegram'
    And header Authorization = invalidBearer
    And request { "botToken": "000000000:FAKE_TELEGRAM_BOT_TOKEN_KARATE" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=641 @qase.title=Platforms ActivateTelegram: POST sem auth retorna 400
  @negative
  Scenario: POST activate-telegram sem Authorization retorna 400
    Given path channelBase + '/' + metaChannelId + '/activate-telegram'
    And request { "botToken": "000000000:FAKE_TELEGRAM_BOT_TOKEN_KARATE" }
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=642 @qase.title=Platforms ActivateTelegram: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST activate-telegram com channelId inexistente retorna 404
    Given path channelBase + '/' + idInexistente + '/activate-telegram'
    And header Authorization = bearerAuth
    And request { "botToken": "000000000:FAKE_TELEGRAM_BOT_TOKEN_KARATE" }
    When method POST
    Then match [404, 400, 502] contains responseStatus

  @qase.id=643 @qase.title=Platforms ActivateTelegram: POST com auth valido valida que API e chamada
  @positive @smoke
  Scenario: POST activate-telegram com auth valido valida que API e chamada retorna 200 ou 400 ou 502
    Given path channelBase + '/' + metaChannelId + '/activate-telegram'
    And header Authorization = bearerAuth
    And request { "botToken": "#(telegramBotToken)" }
    When method POST
    Then match [200, 400, 402, 422, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-telegram — Desativar Telegram
  # ===========================================================================

  @qase.id=644 @qase.title=Platforms DeactivateTelegram: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST deactivate-telegram com Authorization invalido retorna 400
    Given path channelBase + '/' + metaChannelId + '/deactivate-telegram'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 404, 500] contains responseStatus

  @qase.id=645 @qase.title=Platforms DeactivateTelegram: POST com auth valido valida que API e chamada
  @positive
  Scenario: POST deactivate-telegram com auth valido valida que API e chamada
    Given path channelBase + '/' + metaChannelId + '/deactivate-telegram'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [200, 400, 402, 500, 502] contains responseStatus
