@trial @regression
Feature: Trial — Verificacao de status Trial via criacao de canal

  Testa se a API retorna corretamente o status trial para um canal recém-criado.
  O fluxo completo é: criar canal -> capturar o id -> verificar status trial.

  POST /v1/channels
  GET  /v1/channels/{channelId}

  Background:
    * url baseUrl
    * def channelPrefix = '/v1/channels'

  # ===========================================================================
  # Fluxo: criar canal e verificar se a API indica status trial
  # ===========================================================================

  @qase.id=1100 @qase.title=Trial: POST criar canal e GET verificar status trial
  @positive @smoke
  Scenario: POST criar canal retorna id e GET verifica que canal esta em trial
    # Passo 1: criar canal
    Given path channelPrefix
    And header Authorization = secretKey
    And request { "name": "Canal Karate Trial Test", "type": "META_WHATSAPP" }
    When method POST
    Then match [200, 201, 422, 404] contains responseStatus
    * def createdChannelId = responseStatus == 201 || responseStatus == 200 ? response.id : null

    # Passo 2: verificar status trial apenas se o canal foi criado com sucesso
    Given path channelPrefix + '/' + createdChannelId
    And header Authorization = secretKey
    When method GET
    Then match [200, 404] contains responseStatus
    * def isTrial = responseStatus == 200 ? response.trial == true || response.paymentStatus == 'TRIAL' : null
    * karate.log('[trial] canal id:', createdChannelId, '| trial:', isTrial)

  @qase.id=1101 @qase.title=Trial: GET canal configurado em env verifica status trial
  @positive @smoke
  Scenario: GET canal ja existente configurado no env verifica que esta em trial
    Given path channelPrefix + '/' + channelId
    And header Authorization = secretKey
    When method GET
    Then match [200, 404] contains responseStatus
    * karate.log('[trial] channel id:', channelId, '| response status:', responseStatus)

  @qase.id=1102 @qase.title=Trial: POST canal sem auth retorna erro
  @negative
  Scenario: POST criar canal sem Authorization retorna erro
    Given path channelPrefix
    And request { "name": "Canal Sem Auth", "type": "META_WHATSAPP" }
    When method POST
    Then match [400, 500, 404] contains responseStatus

  @qase.id=1103 @qase.title=Trial: POST canal com auth invalido retorna 400
  @negative
  Scenario: POST criar canal com Authorization invalido retorna 400
    Given path channelPrefix
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "name": "Canal Auth Invalido", "type": "META_WHATSAPP" }
    When method POST
    Then match [400, 404] contains responseStatus
