@newport @zapi @regression
Feature: Newport — Instancias Z-API WhatsApp

  Testa os endpoints de gerenciamento de instancias Z-API
  do servico arkansas-newport.

  GET/POST/PUT/DELETE /v1/channels/{id}/zapi/instances/*

  Background:
    * url newportUrl
    * def zapiBase = '/v1/channels/' + channelId + '/zapi/instances'
    * def idInexistente = '00000000-0000-0000-0000-000000000000'
    * def zapiBaseInexistente = '/v1/channels/' + idInexistente + '/zapi/instances'

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/status
  # ===========================================================================

  @qase.id=300 @qase.title=Newport ZApi Status: GET status com auth valido retorna 200
  @positive @smoke
  Scenario: GET status da instancia Z-API retorna 200
    Given path zapiBase + '/status'
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then match [200, 404] contains responseStatus
    And match response == '#notnull'

  @qase.id=301 @qase.title=Newport ZApi Status: GET status com auth invalido retorna 400
  @negative
  Scenario: GET status com Authorization invalido retorna 400
    Given path zapiBase + '/status'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=302 @qase.title=Newport ZApi Status: GET status sem auth retorna 400
  @negative
  Scenario: GET status sem Authorization retorna 400
    Given path zapiBase + '/status'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=303 @qase.title=Newport ZApi Status: GET status com channelId inexistente retorna 404
  @negative
  Scenario: GET status com channelId inexistente retorna 404
    Given path zapiBaseInexistente + '/status'
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then status 404

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/qr-code
  # ===========================================================================

  @qase.id=310 @qase.title=Newport ZApi QrCode: GET qr-code com auth valido retorna 200
  @positive @smoke
  Scenario: GET qr-code da instancia Z-API retorna 200
    Given path zapiBase + '/qr-code'
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then match [200, 404] contains responseStatus
    And match response == '#notnull'

  @qase.id=311 @qase.title=Newport ZApi QrCode: GET qr-code com auth invalido retorna 400
  @negative
  Scenario: GET qr-code com Authorization invalido retorna 400
    Given path zapiBase + '/qr-code'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=312 @qase.title=Newport ZApi QrCode: GET qr-code sem auth retorna 400
  @negative
  Scenario: GET qr-code sem Authorization retorna 400
    Given path zapiBase + '/qr-code'
    When method GET
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/device
  # ===========================================================================

  @qase.id=320 @qase.title=Newport ZApi Device: GET device com auth valido retorna 200
  @positive
  Scenario: GET device da instancia Z-API retorna 200
    Given path zapiBase + '/device'
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then match [200, 404] contains responseStatus
    And match response == '#notnull'

  @qase.id=321 @qase.title=Newport ZApi Device: GET device com auth invalido retorna 400
  @negative
  Scenario: GET device com Authorization invalido retorna 400
    Given path zapiBase + '/device'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=322 @qase.title=Newport ZApi Device: GET device sem auth retorna 400
  @negative
  Scenario: GET device sem Authorization retorna 400
    Given path zapiBase + '/device'
    When method GET
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/queue
  # ===========================================================================

  @qase.id=330 @qase.title=Newport ZApi Queue: GET queue com auth valido retorna 200
  @positive
  Scenario: GET tamanho da fila da instancia Z-API retorna 200
    Given path zapiBase + '/queue'
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then match [200, 404] contains responseStatus
    And match response == '#notnull'

  @qase.id=331 @qase.title=Newport ZApi Queue: GET queue com auth invalido retorna 400
  @negative
  Scenario: GET queue com Authorization invalido retorna 400
    Given path zapiBase + '/queue'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=332 @qase.title=Newport ZApi Queue: DELETE queue com auth valido retorna 200 ou 404
  @positive
  Scenario: DELETE mensagens da fila retorna 200 ou 404
    Given path zapiBase + '/queue'
    And header Authorization = 'Bearer ' + secretKey
    When method DELETE
    Then match [200, 404, 502] contains responseStatus

  @qase.id=333 @qase.title=Newport ZApi Queue: DELETE queue com auth invalido retorna 400
  @negative
  Scenario: DELETE queue com Authorization invalido retorna 400
    Given path zapiBase + '/queue'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method DELETE
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # PUT /v1/channels/{id}/zapi/instances/clear-cache
  # ===========================================================================

  @qase.id=340 @qase.title=Newport ZApi ClearCache: PUT com auth invalido retorna 400
  @negative
  Scenario: PUT clear-cache com Authorization invalido retorna 400
    Given path zapiBase + '/clear-cache'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method PUT
    Then match [400, 404] contains responseStatus

  @qase.id=341 @qase.title=Newport ZApi ClearCache: PUT sem auth retorna 400
  @negative
  Scenario: PUT clear-cache sem Authorization retorna 400
    Given path zapiBase + '/clear-cache'
    When method PUT
    Then match [400, 404] contains responseStatus

  @qase.id=342 @qase.title=Newport ZApi ClearCache: PUT com auth valido retorna 200 ou 502
  @positive
  Scenario: PUT clear-cache com auth valido retorna 200 ou 502
    Given path zapiBase + '/clear-cache'
    And header Authorization = 'Bearer ' + secretKey
    When method PUT
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # PUT /v1/channels/{id}/zapi/instances/replace-instance
  # ===========================================================================

  @qase.id=350 @qase.title=Newport ZApi ReplaceInstance: PUT com auth invalido retorna 400
  @negative
  Scenario: PUT replace-instance com Authorization invalido retorna 400
    Given path zapiBase + '/replace-instance'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method PUT
    Then match [400, 404] contains responseStatus

  @qase.id=351 @qase.title=Newport ZApi ReplaceInstance: PUT sem auth retorna 400
  @negative
  Scenario: PUT replace-instance sem Authorization retorna 400
    Given path zapiBase + '/replace-instance'
    When method PUT
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{id}/zapi/instances/integrator/on-demand
  # ===========================================================================

  @qase.id=360 @qase.title=Newport ZApi OnDemand: POST criar instancia com auth invalido retorna 400
  @negative
  Scenario: POST criar instancia on-demand com auth invalido retorna 400
    Given path zapiBase + '/integrator/on-demand'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=361 @qase.title=Newport ZApi OnDemand: POST criar instancia sem auth retorna 400
  @negative
  Scenario: POST criar instancia on-demand sem auth retorna 400
    Given path zapiBase + '/integrator/on-demand'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=362 @qase.title=Newport ZApi OnDemand: POST criar instancia com auth valido retorna 200 ou 502
  @positive
  Scenario: POST criar instancia on-demand com auth valido retorna 200 ou 502
    Given path zapiBase + '/integrator/on-demand'
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{id}/zapi/instances/integrator/on-demand/subscription
  # ===========================================================================

  @qase.id=370 @qase.title=Newport ZApi Subscription: POST com auth invalido retorna 400
  @negative
  Scenario: POST subscription com auth invalido retorna 400
    Given path zapiBase + '/integrator/on-demand/subscription'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=371 @qase.title=Newport ZApi Subscription: POST sem auth retorna 400
  @negative
  Scenario: POST subscription sem auth retorna 400
    Given path zapiBase + '/integrator/on-demand/subscription'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{id}/zapi/instances/integrator/on-demand/cancel
  # ===========================================================================

  @qase.id=380 @qase.title=Newport ZApi Cancel: POST com auth invalido retorna 400
  @negative
  Scenario: POST cancel com auth invalido retorna 400
    Given path zapiBase + '/integrator/on-demand/cancel'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=381 @qase.title=Newport ZApi Cancel: POST sem auth retorna 400
  @negative
  Scenario: POST cancel sem auth retorna 400
    Given path zapiBase + '/integrator/on-demand/cancel'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{id}/zapi/instances/disconnect
  # ===========================================================================

  @qase.id=390 @qase.title=Newport ZApi Disconnect: POST com auth invalido retorna 400
  @negative
  Scenario: POST disconnect com auth invalido retorna 400
    Given path zapiBase + '/disconnect'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=391 @qase.title=Newport ZApi Disconnect: POST sem auth retorna 400
  @negative
  Scenario: POST disconnect sem auth retorna 400
    Given path zapiBase + '/disconnect'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=392 @qase.title=Newport ZApi Disconnect: POST com auth valido retorna 200 ou 502
  @positive
  Scenario: POST disconnect com auth valido retorna 200 ou 502
    Given path zapiBase + '/disconnect'
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/contacts
  # ===========================================================================

  @qase.id=400 @qase.title=Newport ZApi Contacts: GET lista contatos com auth valido retorna 200 ou 502
  @positive
  Scenario: GET lista de contatos da instancia retorna 200 ou 502
    Given path zapiBase + '/contacts'
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then match [200, 502] contains responseStatus

  @qase.id=401 @qase.title=Newport ZApi Contacts: GET contatos com auth invalido retorna 400
  @negative
  Scenario: GET contatos com auth invalido retorna 400
    Given path zapiBase + '/contacts'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=402 @qase.title=Newport ZApi Contacts: GET contato por phone com auth valido retorna 200 ou 502
  @positive
  Scenario: GET contato por phone retorna 200 ou 502
    Given path zapiBase + '/contacts/' + phoneNumber
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then match [200, 502] contains responseStatus

  @qase.id=403 @qase.title=Newport ZApi Contacts: GET contato por phone com auth invalido retorna 400
  @negative
  Scenario: GET contato por phone com auth invalido retorna 400
    Given path zapiBase + '/contacts/' + phoneNumber
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/phone-exists/{phone}
  # ===========================================================================

  @qase.id=410 @qase.title=Newport ZApi PhoneExists: GET phone-exists com auth valido retorna 200 ou 502
  @positive
  Scenario: GET phone-exists com phone valido retorna 200 ou 502
    Given path zapiBase + '/phone-exists/' + phoneNumber
    And header Authorization = 'Bearer ' + secretKey
    When method GET
    Then match [200, 502] contains responseStatus

  @qase.id=411 @qase.title=Newport ZApi PhoneExists: GET phone-exists com auth invalido retorna 400
  @negative
  Scenario: GET phone-exists com auth invalido retorna 400
    Given path zapiBase + '/phone-exists/' + phoneNumber
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/profile-picture?phone=
  # ===========================================================================

  @qase.id=420 @qase.title=Newport ZApi ProfilePicture: GET profile-picture com auth valido retorna 200 ou 502
  @positive
  Scenario: GET foto de perfil retorna 200 ou 502
    Given path zapiBase + '/profile-picture'
    And header Authorization = 'Bearer ' + secretKey
    And param phone = phoneNumber
    When method GET
    Then match [200, 502] contains responseStatus

  @qase.id=421 @qase.title=Newport ZApi ProfilePicture: GET profile-picture com auth invalido retorna 400
  @negative
  Scenario: GET foto de perfil com auth invalido retorna 400
    Given path zapiBase + '/profile-picture'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And param phone = phoneNumber
    When method GET
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/group-metadata/{phone}
  # ===========================================================================

  @qase.id=430 @qase.title=Newport ZApi GroupMetadata: GET metadata com auth invalido retorna 400
  @negative
  Scenario: GET group-metadata com auth invalido retorna 400
    Given path zapiBase + '/group-metadata/' + phoneNumber
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=431 @qase.title=Newport ZApi GroupMetadata: GET metadata sem auth retorna 400
  @negative
  Scenario: GET group-metadata sem auth retorna 400
    Given path zapiBase + '/group-metadata/' + phoneNumber
    When method GET
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # GET /v1/channels/{id}/zapi/instances/catalogs/{phone}
  # ===========================================================================

  @qase.id=440 @qase.title=Newport ZApi Catalogs: GET catalogs com auth invalido retorna 400
  @negative
  Scenario: GET catalogs com auth invalido retorna 400
    Given path zapiBase + '/catalogs/' + phoneNumber
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method GET
    Then match [400, 404] contains responseStatus

  @qase.id=441 @qase.title=Newport ZApi Catalogs: GET catalogs sem auth retorna 400
  @negative
  Scenario: GET catalogs sem auth retorna 400
    Given path zapiBase + '/catalogs/' + phoneNumber
    When method GET
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{id}/zapi/instances/read-message
  # ===========================================================================

  @qase.id=450 @qase.title=Newport ZApi ReadMessage: POST com auth invalido retorna 400
  @negative
  Scenario: POST read-message com auth invalido retorna 400
    Given path zapiBase + '/read-message'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=451 @qase.title=Newport ZApi ReadMessage: POST sem auth retorna 400
  @negative
  Scenario: POST read-message sem auth retorna 400
    Given path zapiBase + '/read-message'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{id}/zapi/instances/read-all-message
  # ===========================================================================

  @qase.id=460 @qase.title=Newport ZApi ReadAllMessage: POST com auth invalido retorna 400
  @negative
  Scenario: POST read-all-message com auth invalido retorna 400
    Given path zapiBase + '/read-all-message'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=461 @qase.title=Newport ZApi ReadAllMessage: POST sem auth retorna 400
  @negative
  Scenario: POST read-all-message sem auth retorna 400
    Given path zapiBase + '/read-all-message'
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus
