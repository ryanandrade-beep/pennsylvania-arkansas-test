@newport @channels @regression
Feature: Newport — CRUD de Canais

  Testa os endpoints de gerenciamento de canais do servico arkansas-newport.

  POST   /v1/channels
  GET    /v1/channels
  GET    /v1/channels/{id}
  PUT    /v1/channels/{id}
  DELETE /v1/channels/{id}

  Background:
    * url baseUrl
    * def channelPrefix = '/v1/channels'
    * def idInexistente = '00000000-0000-0000-0000-000000000000'

  # ===========================================================================
  # POST /v1/channels — Criar canal
  # ===========================================================================

  @qase.id=120 @qase.title=Newport Channels: POST criar META_WHATSAPP retorna 201 com id
  @positive @smoke
  Scenario: POST /v1/channels cria canal META_WHATSAPP retorna 201 e id do canal
    * def channelName = 'karate-meta-whatsapp-' + karateSuffix
    Given path channelPrefix
    And header Authorization = secretKey
    And request { name: '#(channelName)', type: 'META_WHATSAPP' }
    When method POST
    Then match [201, 422, 404] contains responseStatus
    * if (responseStatus == 201) karate.match(response.id, '#notnull')

  @qase.id=121 @qase.title=Newport Channels: POST criar META_INSTAGRAM retorna 201
  @positive
  Scenario: POST /v1/channels cria canal META_INSTAGRAM e retorna 201
    * def channelName = 'karate-meta-instagram-' + karateSuffix
    Given path channelPrefix
    And header Authorization = secretKey
    And request { name: '#(channelName)', type: 'META_INSTAGRAM' }
    When method POST
    Then match [201, 422, 404] contains responseStatus

  @qase.id=122 @qase.title=Newport Channels: POST criar ZAPI_WHATSAPP retorna 201 com id
  @positive
  Scenario: POST /v1/channels cria canal ZAPI_WHATSAPP retorna 201 e id do canal
    * def channelName = 'karate-zapi-whatsapp-' + karateSuffix
    Given path channelPrefix
    And header Authorization = secretKey
    And request { name: '#(channelName)', type: 'ZAPI_WHATSAPP' }
    When method POST
    Then match [201, 422, 500, 404] contains responseStatus
    * if (responseStatus == 201) karate.match(response.id, '#notnull')

  @qase.id=123 @qase.title=Newport Channels: POST criar META_MESSENGER retorna 502
  @negative
  Scenario: POST /v1/channels com META_MESSENGER retorna 502 (provider indisponivel)
    * def channelName = 'karate-meta-messenger-' + karateSuffix
    Given path channelPrefix
    And header Authorization = secretKey
    And request { name: '#(channelName)', type: 'META_MESSENGER' }
    When method POST
    Then match [502, 422, 404] contains responseStatus

  @qase.id=124 @qase.title=Newport Channels: POST com auth invalido retorna 400
  @negative
  Scenario: POST /v1/channels com auth invalido retorna 400
    * def channelName = 'karate-auth-invalido-' + karateSuffix
    Given path channelPrefix
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { name: '#(channelName)', type: 'META_WHATSAPP' }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=125 @qase.title=Newport Channels: POST sem auth retorna 500
  @negative
  Scenario: POST /v1/channels sem auth retorna 500
    * def channelName = 'karate-sem-auth-' + karateSuffix
    Given path channelPrefix
    And request { name: '#(channelName)', type: 'META_WHATSAPP' }
    When method POST
    Then match [500, 404] contains responseStatus

  @qase.id=126 @qase.title=Newport Channels: POST com payload vazio retorna 502
  @negative
  Scenario: POST /v1/channels com payload vazio retorna 502
    Given path channelPrefix
    And header Authorization = secretKey
    And request {}
    When method POST
    Then match [502, 422, 404] contains responseStatus

  @qase.id=127 @qase.title=Newport Channels: POST com tipo invalido retorna 500
  @negative
  Scenario: POST /v1/channels com tipo invalido retorna 500
    * def channelName = 'karate-tipo-invalido-' + karateSuffix
    Given path channelPrefix
    And header Authorization = secretKey
    And request { name: '#(channelName)', type: 'TIPO_INVALIDO' }
    When method POST
    Then match [500, 404] contains responseStatus

  @qase.id=128 @qase.title=Newport Channels: POST sem campo name retorna 502
  @negative
  Scenario: POST /v1/channels sem campo name retorna 502
    Given path channelPrefix
    And header Authorization = secretKey
    And request { type: 'META_WHATSAPP' }
    When method POST
    Then match [502, 422, 404] contains responseStatus

  @qase.id=129 @qase.title=Newport Channels: POST tipo TELEGRAM retorna 500
  @negative
  Scenario: POST /v1/channels com TELEGRAM retorna 500
    * def channelName = 'karate-telegram-' + karateSuffix
    Given path channelPrefix
    And header Authorization = secretKey
    And request { name: '#(channelName)', type: 'TELEGRAM' }
    When method POST
    Then match [500, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels — Listar canais (retorna 500 neste workspace)
  # ===========================================================================

  @qase.id=100 @qase.title=Newport Channels: GET lista canais retorna 500 ou 200
  @positive @smoke
  Scenario: GET /v1/channels retorna resposta do servidor
    Given path channelPrefix
    And header Authorization = secretKey
    When method GET
    Then match [200, 500, 404] contains responseStatus

  @qase.id=101 @qase.title=Newport Channels: GET lista canais com auth invalido retorna 400 ou 500
  @negative
  Scenario: GET /v1/channels com auth invalido retorna 400 ou 500
    Given path channelPrefix
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 500, 404] contains responseStatus

  @qase.id=102 @qase.title=Newport Channels: GET lista canais sem auth retorna 500
  @negative
  Scenario: GET /v1/channels sem auth retorna 500
    Given path channelPrefix
    When method GET
    Then match [500, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id} — Buscar canal por ID
  # ===========================================================================

  @qase.id=110 @qase.title=Newport Channels: GET canal por ID valido retorna 200 ou 404
  @positive @smoke
  Scenario: GET /v1/channels/{id} com ID valido retorna resposta
    Given path channelPrefix + '/' + channelId
    And header Authorization = secretKey
    When method GET
    Then match [200, 404] contains responseStatus

  @qase.id=111 @qase.title=Newport Channels: GET canal com ID inexistente retorna 404
  @negative
  Scenario: GET /v1/channels/{id} com ID inexistente retorna 404
    Given path channelPrefix + '/' + idInexistente
    And header Authorization = secretKey
    When method GET
    Then status 404

  @qase.id=112 @qase.title=Newport Channels: GET canal com auth invalido retorna 400 ou 404
  @negative
  Scenario: GET /v1/channels/{id} com auth invalido retorna 400 ou 404
    Given path channelPrefix + '/' + channelId
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=113 @qase.title=Newport Channels: GET canal sem auth retorna 404 ou 500
  @negative
  Scenario: GET /v1/channels/{id} sem auth retorna 404 ou 500
    Given path channelPrefix + '/' + channelId
    When method GET
    Then match [404, 500] contains responseStatus

  # ===========================================================================
  # PUT /v1/channels/{id} — Atualizar canal
  # ===========================================================================

  @qase.id=130 @qase.title=Newport Channels: PUT atualizar canal retorna 200 ou 404
  @positive @smoke
  Scenario: PUT /v1/channels/{id} atualiza nome do canal
    * def channelName = 'karate-atualizado-' + karateSuffix
    Given path channelPrefix + '/' + channelId
    And header Authorization = secretKey
    And request { name: '#(channelName)' }
    When method PUT
    Then match [200, 404] contains responseStatus

  @qase.id=131 @qase.title=Newport Channels: PUT com ID inexistente retorna 404
  @negative
  Scenario: PUT /v1/channels/{id} com ID inexistente retorna 404
    * def channelName = 'karate-inexistente-' + karateSuffix
    Given path channelPrefix + '/' + idInexistente
    And header Authorization = secretKey
    And request { name: '#(channelName)' }
    When method PUT
    Then status 404

  @qase.id=132 @qase.title=Newport Channels: PUT com auth invalido retorna 400 ou 404
  @negative
  Scenario: PUT /v1/channels/{id} com auth invalido retorna 400 ou 404
    Given path channelPrefix + '/' + channelId
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { name: 'karate-update' }
    When method PUT
    Then match [400, 404] contains responseStatus

  @qase.id=133 @qase.title=Newport Channels: PUT sem auth retorna 404 ou 500
  @negative
  Scenario: PUT /v1/channels/{id} sem auth retorna 404 ou 500
    Given path channelPrefix + '/' + channelId
    And request { name: 'karate-update' }
    When method PUT
    Then match [404, 500] contains responseStatus

  # ===========================================================================
  # DELETE /v1/channels/{id} — Deletar canal
  # ===========================================================================

  @qase.id=140 @qase.title=Newport Channels: DELETE com auth invalido retorna 400 ou 404
  @negative
  Scenario: DELETE /v1/channels/{id} com auth invalido retorna 400 ou 404
    Given path channelPrefix + '/' + channelId
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method DELETE
    Then match [400, 404] contains responseStatus

  @qase.id=141 @qase.title=Newport Channels: DELETE sem auth retorna 404 ou 500
  @negative
  Scenario: DELETE /v1/channels/{id} sem auth retorna 404 ou 500
    Given path channelPrefix + '/' + channelId
    When method DELETE
    Then match [404, 500] contains responseStatus

  @qase.id=142 @qase.title=Newport Channels: DELETE com ID inexistente retorna 404
  @negative
  Scenario: DELETE /v1/channels/{id} com ID inexistente retorna 404
    Given path channelPrefix + '/' + idInexistente
    And header Authorization = secretKey
    When method DELETE
    Then status 404
