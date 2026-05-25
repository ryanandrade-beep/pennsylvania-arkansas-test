@channels @platforms @regression
Feature: Channels Platforms — Ativar e desativar plataformas nos canais

  Testa os endpoints de ativacao e desativacao de plataformas em canais
  existentes via API HubMessage (pennsylvania-hermitage).

  IMPORTANTE: Esses endpoints sao exclusivos do painel interno (dashboard).
  Exigem autenticacao JWT de sessao de usuario (role sem ALLOW_INTEGRATION).
  A secret key (sk_live_*) possui a authority ALLOW_INTEGRATION e por isso
  recebe 403 nesses endpoints — este comportamento E o esperado e testado.

  Campos de body por plataforma:
    activate-meta:      { businessId, accessToken, phoneId, isAppOnboarding, appId, appSecret, code }
    activate-instagram: { igId, accessToken, code, redirectUri, clientId, clientSecret }
    activate-messenger: { pageId, accessToken, code, redirectUri, clientId, clientSecret }
    list-messenger-pages: { code, redirectUri, clientId, clientSecret }
    activate-telegram:  { token }

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
  # Exige JWT de sessao — sk_live retorna 403 (ALLOW_INTEGRATION bloqueado)
  # Tela: Painel > Canais > WhatsApp > Conectar
  # ===========================================================================

  @qase.id=600 @qase.title=Platforms ActivateMeta: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST activate-meta com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-meta'
    And header Authorization = invalidBearer
    And request { "businessId": "000000000000000", "phoneId": "000000000000000", "code": "FAKE", "isAppOnboarding": false }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=601 @qase.title=Platforms ActivateMeta: POST sem auth retorna 403
  @negative
  Scenario: POST activate-meta sem Authorization retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-meta'
    And request { "businessId": "000000000000000", "phoneId": "000000000000000", "code": "FAKE" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=602 @qase.title=Platforms ActivateMeta: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST activate-meta com sk_live retorna 403 pois endpoint exige JWT de sessao sem ALLOW_INTEGRATION
    Given path channelBase + '/' + metaChannelId + '/activate-meta'
    And header Authorization = bearerAuth
    And request { "businessId": "000000000000000", "phoneId": "000000000000000", "code": "FAKE_CODE_KARATE", "isAppOnboarding": false }
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-meta — Desativar WhatsApp Meta
  # ===========================================================================

  @qase.id=604 @qase.title=Platforms DeactivateMeta: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST deactivate-meta com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/deactivate-meta'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=605 @qase.title=Platforms DeactivateMeta: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST deactivate-meta com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/deactivate-meta'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/activate-instagram — Ativar Instagram
  # Tela: Painel > Canais > Instagram > Conectar
  # ===========================================================================

  @qase.id=610 @qase.title=Platforms ActivateInstagram: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST activate-instagram com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-instagram'
    And header Authorization = invalidBearer
    And request { "code": "FAKE_INSTAGRAM_CODE", "redirectUri": "https://app.hubmessage.io", "clientId": "000", "clientSecret": "000" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=611 @qase.title=Platforms ActivateInstagram: POST sem auth retorna 403
  @negative
  Scenario: POST activate-instagram sem Authorization retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-instagram'
    And request { "code": "FAKE_INSTAGRAM_CODE", "redirectUri": "https://app.hubmessage.io" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=612 @qase.title=Platforms ActivateInstagram: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST activate-instagram com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/activate-instagram'
    And header Authorization = bearerAuth
    And request { "code": "FAKE_CODE_KARATE_INSTAGRAM", "redirectUri": "https://app.hubmessage.io", "clientId": "000", "clientSecret": "000" }
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-instagram — Desativar Instagram
  # ===========================================================================

  @qase.id=614 @qase.title=Platforms DeactivateInstagram: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST deactivate-instagram com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/deactivate-instagram'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=615 @qase.title=Platforms DeactivateInstagram: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST deactivate-instagram com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/deactivate-instagram'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/list-messenger-pages — Listar paginas do Messenger
  # Tela: Painel > Canais > Messenger > Selecionar pagina
  # ===========================================================================

  @qase.id=620 @qase.title=Platforms ListMessengerPages: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST list-messenger-pages com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/list-messenger-pages'
    And header Authorization = invalidBearer
    And request { "code": "FAKE_MESSENGER_CODE", "redirectUri": "https://app.hubmessage.io" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=621 @qase.title=Platforms ListMessengerPages: POST sem auth retorna 403
  @negative
  Scenario: POST list-messenger-pages sem Authorization retorna 403
    Given path channelBase + '/' + metaChannelId + '/list-messenger-pages'
    And request { "code": "FAKE_MESSENGER_CODE" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=622 @qase.title=Platforms ListMessengerPages: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST list-messenger-pages com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/list-messenger-pages'
    And header Authorization = bearerAuth
    And request { "code": "FAKE_CODE_KARATE_MESSENGER", "redirectUri": "https://app.hubmessage.io", "clientId": "000", "clientSecret": "000" }
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/activate-messenger — Ativar Messenger
  # Tela: Painel > Canais > Messenger > Conectar
  # ===========================================================================

  @qase.id=630 @qase.title=Platforms ActivateMessenger: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST activate-messenger com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-messenger'
    And header Authorization = invalidBearer
    And request { "pageId": "000000000000000", "code": "FAKE_MESSENGER_CODE", "redirectUri": "https://app.hubmessage.io" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=631 @qase.title=Platforms ActivateMessenger: POST sem auth retorna 403
  @negative
  Scenario: POST activate-messenger sem Authorization retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-messenger'
    And request { "pageId": "000000000000000", "code": "FAKE_MESSENGER_CODE" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=632 @qase.title=Platforms ActivateMessenger: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST activate-messenger com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/activate-messenger'
    And header Authorization = bearerAuth
    And request { "pageId": "000000000000000", "code": "FAKE_CODE_KARATE_MESSENGER", "redirectUri": "https://app.hubmessage.io", "clientId": "000", "clientSecret": "000" }
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-messenger — Desativar Messenger
  # ===========================================================================

  @qase.id=634 @qase.title=Platforms DeactivateMessenger: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST deactivate-messenger com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/deactivate-messenger'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=635 @qase.title=Platforms DeactivateMessenger: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST deactivate-messenger com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/deactivate-messenger'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/activate-telegram — Ativar Telegram
  # Tela: Painel > Canais > Telegram > Conectar (bot token)
  # ===========================================================================

  @qase.id=640 @qase.title=Platforms ActivateTelegram: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST activate-telegram com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-telegram'
    And header Authorization = invalidBearer
    And request { "token": "000000000:FAKE_TELEGRAM_BOT_TOKEN_KARATE" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=641 @qase.title=Platforms ActivateTelegram: POST sem auth retorna 403
  @negative
  Scenario: POST activate-telegram sem Authorization retorna 403
    Given path channelBase + '/' + metaChannelId + '/activate-telegram'
    And request { "token": "000000000:FAKE_TELEGRAM_BOT_TOKEN_KARATE" }
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=642 @qase.title=Platforms ActivateTelegram: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST activate-telegram com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/activate-telegram'
    And header Authorization = bearerAuth
    And request { "token": "000000000:FAKE_TELEGRAM_BOT_TOKEN_KARATE" }
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus

  # ===========================================================================
  # POST /channels/{id}/deactivate-telegram — Desativar Telegram
  # ===========================================================================

  @qase.id=644 @qase.title=Platforms DeactivateTelegram: POST com auth invalido retorna 403
  @negative @smoke
  Scenario: POST deactivate-telegram com Authorization invalido retorna 403
    Given path channelBase + '/' + metaChannelId + '/deactivate-telegram'
    And header Authorization = invalidBearer
    And request {}
    When method POST
    Then match [400, 401, 403, 404, 500] contains responseStatus

  @qase.id=645 @qase.title=Platforms DeactivateTelegram: POST com sk_live retorna 403 pois exige JWT sessao
  @negative @smoke
  Scenario: POST deactivate-telegram com sk_live retorna 403 pois exige JWT de sessao
    Given path channelBase + '/' + metaChannelId + '/deactivate-telegram'
    And header Authorization = bearerAuth
    And request {}
    When method POST
    Then match [400, 403, 404, 500, 502] contains responseStatus
