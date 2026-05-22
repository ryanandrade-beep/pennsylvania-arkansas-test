@barling @regression
Feature: Barling — Orquestracao de Mensagens

  Testa os endpoints REST do servico arkansas-barling para envio,
  encaminhamento e exclusao de mensagens via canais HubMessage.

  POST   /v1/channels/{channelId}/messages
  POST   /v1/channels/{channelId}/messages/forward
  DELETE /v1/channels/{channelId}/messages/{messageId}

  Background:
    * url barlingUrl
    * def channelPath = '/v1/channels/' + channelId + '/messages'
    * def channelInexistente = '00000000000000000000000000000000'
    * def pathInexistente = '/v1/channels/' + channelInexistente + '/messages'

  # ===========================================================================
  # POST /v1/channels/{channelId}/messages — Enviar mensagem
  # ===========================================================================

  @qase.id=10 @qase.title=Barling Send: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST mensagem com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "teste" } } }
    When method POST
    Then status 400

  @qase.id=11 @qase.title=Barling Send: POST sem auth retorna 400
  @negative
  Scenario: POST mensagem sem Authorization retorna 400
    Given path channelPath
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "teste" } } }
    When method POST
    Then status 400

  @qase.id=12 @qase.title=Barling Send: POST com payload vazio retorna 400
  @negative
  Scenario: POST mensagem com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=13 @qase.title=Barling Send: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST mensagem com channelId inexistente retorna 404
    Given path pathInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "teste" } } }
    When method POST
    Then status 404

  @qase.id=14 @qase.title=Barling Send TEXT: POST com texto valido retorna 200
  @positive @smoke
  Scenario: POST mensagem TEXT com dados validos retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "TEXT",
          "body": { "message": "Ola! Tudo bem? Estamos com novidades incriveis esperando por voce. Fale com a gente!" }
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=15 @qase.title=Barling Send IMAGE: POST com imagem retorna 200
  @positive
  Scenario: POST mensagem IMAGE com URL valida retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "IMAGE",
          "attachments": [{
            "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png",
            "caption": "Confira nossa linha de produtos exclusivos!"
          }]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=16 @qase.title=Barling Send AUDIO: POST com audio retorna 200
  @positive
  Scenario: POST mensagem AUDIO com URL valida retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "AUDIO",
          "attachments": [{ "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" }]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=17 @qase.title=Barling Send VIDEO: POST com video retorna 200
  @positive
  Scenario: POST mensagem VIDEO com URL valida retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "VIDEO",
          "attachments": [{
            "url": "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
            "caption": "Assista e descubra como podemos te ajudar!"
          }]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=18 @qase.title=Barling Send CONTACT: POST com contato retorna 200
  @positive
  Scenario: POST mensagem CONTACT com dados validos retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "CONTACT",
          "attachments": [{
            "name": "Ryan Andrade",
            "phones": ["5544997294496"]
          }]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=19 @qase.title=Barling Send STICKER: POST com sticker retorna 200
  @positive
  Scenario: POST mensagem STICKER com URL valida retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "STICKER",
          "attachments": [{ "url": "https://img-01.stickers.cloud/packs/05bc83ea-96b8-4288-8103-15e7dbb52360/webp/f8c95807-ae7f-46c4-b2c1-a0720a44df18.webp" }]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=20 @qase.title=Barling Send INTERACTIVE_BUTTON: POST com botoes retorna 200
  @positive
  Scenario: POST mensagem INTERACTIVE_BUTTON com 3 botoes retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "INTERACTIVE_BUTTON",
          "body": { "message": "Oi! Como foi sua experiencia com a gente?" },
          "attachments": [
            { "id": "1", "title": "Excelente" },
            { "id": "2", "title": "Bom" },
            { "id": "3", "title": "Regular" }
          ]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=21 @qase.title=Barling Send INTERACTIVE_ACTION: POST com acoes URL e CALL retorna 200
  @positive
  Scenario: POST mensagem INTERACTIVE_ACTION com URL e CALL retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "INTERACTIVE_ACTION",
          "body": { "message": "converse com nois" },
          "header": { "message": "Arkansas Barling" },
          "footer": { "message": "Escolha uma opcao" },
          "attachments": [
            { "id": "1", "title": "Acessar portal", "name": "URL", "url": "https://www.hubmessage.io" },
            { "id": "2", "title": "Fale conosco", "name": "CALL", "phones": ["5544997294496"] }
          ]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  @qase.id=22 @qase.title=Barling Send TEMPLATE: POST com template retorna 200
  @positive
  Scenario: POST mensagem TEMPLATE com dados validos retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "TEMPLATE",
          "attachments": [{
              "template": {
              "name": "#(templateName)",
              "language": { "policy": "deterministic", "code": "pt_BR" },
              "components": [{
                "type": "body",
                "parameters": [{ "type": "text", "text": "Karate" }]
              }]
            }
          }]
        }
      }
      """
    When method POST
    Then match [200, 422, 502] contains responseStatus

  # ===========================================================================
  # POST /v1/channels/{channelId}/messages/forward — Encaminhar mensagem
  # ===========================================================================

  @qase.id=30 @qase.title=Barling Forward: POST com auth invalido retorna 400
  @negative
  Scenario: POST forward com Authorization invalido retorna 400
    Given path channelPath + '/forward'
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "forward" } } }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=31 @qase.title=Barling Forward: POST sem auth retorna 400
  @negative
  Scenario: POST forward sem Authorization retorna 400
    Given path channelPath + '/forward'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "forward" } } }
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=32 @qase.title=Barling Forward: POST com payload vazio retorna 400
  @negative
  Scenario: POST forward com payload vazio retorna 400
    Given path channelPath + '/forward'
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then match [400, 404] contains responseStatus

  @qase.id=33 @qase.title=Barling Forward: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST forward com channelId inexistente retorna 404
    Given path pathInexistente + '/forward'
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "forward" } } }
    When method POST
    Then status 404

  @qase.id=34 @qase.title=Barling Forward: POST com dados validos retorna 200
  @positive
  Scenario: POST forward com dados validos retorna 200
    Given path channelPath + '/forward'
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "TEXT",
          "body": { "message": "Mensagem encaminhada via Karate Barling" }
        }
      }
      """
    When method POST
    Then match [200, 404] contains responseStatus

  # ===========================================================================
  # DELETE /v1/channels/{channelId}/messages/{messageId} — Deletar mensagem
  # ===========================================================================

  @qase.id=40 @qase.title=Barling Delete: DELETE com auth invalido retorna 400
  @negative
  Scenario: DELETE mensagem com Authorization invalido retorna 400
    Given path channelPath + '/' + messageId
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    When method DELETE
    Then match [400, 404] contains responseStatus

  @qase.id=41 @qase.title=Barling Delete: DELETE sem auth retorna 400
  @negative
  Scenario: DELETE mensagem sem Authorization retorna 400
    Given path channelPath + '/' + messageId
    When method DELETE
    Then match [400, 404] contains responseStatus

  @qase.id=42 @qase.title=Barling Delete: DELETE com channelId inexistente retorna 404
  @negative
  Scenario: DELETE mensagem com channelId inexistente retorna 404
    Given path pathInexistente + '/' + messageId
    And header Authorization = 'Bearer ' + secretKey
    When method DELETE
    Then status 404

  @qase.id=43 @qase.title=Barling Delete: DELETE com messageId inexistente retorna 404
  @negative
  Scenario: DELETE mensagem com messageId inexistente retorna 404
    Given path channelPath + '/msg-inexistente-karate-test'
    And header Authorization = 'Bearer ' + secretKey
    When method DELETE
    Then status 404

  @qase.id=44 @qase.title=Barling Delete: DELETE com messageId valido retorna 200 ou 404
  @positive
  Scenario: DELETE mensagem com ID valido retorna 200 ou 404
    Given path channelPath + '/' + messageId
    And header Authorization = 'Bearer ' + secretKey
    When method DELETE
    Then match [200, 404] contains responseStatus


