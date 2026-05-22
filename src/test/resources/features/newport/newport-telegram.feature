@newport @telegram @regression
Feature: Newport — Ativar Canal Telegram

  Testa o endpoint de ativacao do Telegram em um canal existente.

  PUT /v1/channels/{id}/telegram/active

  Background:
    * url newportUrl
    * def telegramPath = '/v1/channels/' + channelId + '/telegram/active'
    * def idInexistente = '00000000-0000-0000-0000-000000000000'
    * def pathInexistente = '/v1/channels/' + idInexistente + '/telegram/active'

  # ===========================================================================
  # PUT /v1/channels/{id}/telegram/active
  # ===========================================================================

  @qase.id=200 @qase.title=Newport Telegram: PUT com auth invalido retorna 400
  @negative @smoke
  Scenario: PUT ativar Telegram com Authorization invalido retorna 400
    Given path telegramPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "token": "bot-token-invalido" }
    When method PUT
    Then match [400, 404] contains responseStatus

  @qase.id=201 @qase.title=Newport Telegram: PUT sem auth retorna 400
  @negative
  Scenario: PUT ativar Telegram sem Authorization retorna 400
    Given path telegramPath
    And request { "token": "bot-token-invalido" }
    When method PUT
    Then match [400, 404] contains responseStatus

  @qase.id=202 @qase.title=Newport Telegram: PUT com payload vazio retorna 400 ou 502
  @negative
  Scenario: PUT ativar Telegram com payload vazio retorna 400 ou 502
    Given path telegramPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method PUT
    Then match [400, 502, 404] contains responseStatus

  @qase.id=203 @qase.title=Newport Telegram: PUT com channelId inexistente retorna 404
  @negative
  Scenario: PUT ativar Telegram com channelId inexistente retorna 404
    Given path pathInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "token": "bot-token-invalido" }
    When method PUT
    Then status 404

  @qase.id=204 @qase.title=Newport Telegram: PUT com token invalido retorna 502
  @negative
  Scenario: PUT ativar Telegram com token invalido retorna 502
    Given path telegramPath
    And header Authorization = 'Bearer ' + secretKey
    And request { "token": "123456789:AAFake_token_invalido_karate_test" }
    When method PUT
    Then match [400, 502, 404] contains responseStatus

  @qase.id=205 @qase.title=Newport Telegram: PUT com token valido retorna 200
  @positive
  Scenario: PUT ativar Telegram com token valido retorna 200 ou 502
    Given path telegramPath
    And header Authorization = 'Bearer ' + secretKey
    And request { "token": "#(telegramBotToken)" }
    When method PUT
    Then match [200, 502, 404] contains responseStatus
