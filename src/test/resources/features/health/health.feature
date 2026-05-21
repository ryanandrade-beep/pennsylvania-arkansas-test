@health @smoke @regression
Feature: Health Check — Gateway e Servicos Arkansas

  Valida os endpoints de health check e build info acessiveis
  via gateway publico api.hubmessage.io.

  GET /

  @qase.id=1 @qase.title=Health: GET / no gateway retorna 200
  @positive @smoke
  Scenario: GET / no gateway retorna build info
    Given url baseUrl
    And path '/'
    When method GET
    Then status 200
    And match response == '#notnull'

  @qase.id=2 @qase.title=Health: GET / retorna campo message
  @positive
  Scenario: GET / retorna campo message definido
    Given url baseUrl
    And path '/'
    When method GET
    Then status 200
    And match response.message == '#notnull'

  @qase.id=3 @qase.title=Health Barling: GET / no barlingUrl retorna 200 ou 404
  @positive @barling
  Scenario: GET / no barlingUrl retorna resposta
    Given url barlingUrl
    And path '/'
    When method GET
    Then match [200, 404] contains responseStatus

  @qase.id=4 @qase.title=Health Newport: GET / no newportUrl retorna 200 ou 404
  @positive @newport
  Scenario: GET / no newportUrl retorna resposta
    Given url newportUrl
    And path '/'
    When method GET
    Then match [200, 404] contains responseStatus

  @qase.id=5 @qase.title=Health Conway Z-API: GET / retorna 200 ou 404
  @positive @conway
  Scenario: GET / no conwayZapiUrl retorna resposta
    Given url conwayZapiUrl
    And path '/'
    When method GET
    Then match [200, 404] contains responseStatus

  @qase.id=6 @qase.title=Health Conway Telegram: GET / retorna 200 ou 404
  @positive @conway @telegram
  Scenario: GET / no conwayTelegramUrl retorna resposta
    Given url conwayTelegramUrl
    And path '/'
    When method GET
    Then match [200, 404] contains responseStatus

  @qase.id=7 @qase.title=Health Conway Meta: GET / retorna 200 ou 404
  @positive @conway @meta
  Scenario: GET / no conwayMetaUrl retorna resposta
    Given url conwayMetaUrl
    And path '/'
    When method GET
    Then match [200, 404] contains responseStatus

  @qase.id=8 @qase.title=Health: API responde em menos de 5 segundos
  @positive @smoke
  Scenario: GET / responde em menos de 5 segundos
    Given url baseUrl
    And path '/'
    When method GET
    Then status 200
    And assert responseTime < 5000
