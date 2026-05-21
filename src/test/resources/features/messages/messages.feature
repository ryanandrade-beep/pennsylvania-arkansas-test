@messages @regression
Feature: Messages — Envio de Mensagens Livres via Canal

  Testa os endpoints de envio de mensagens via canal HubMessage.
  Todos os endpoints usam POST /v1/channels/{channelId}/messages
  com diferentes tipos de conteudo.

  POST /v1/channels/{channelId}/messages

  Background:
    * url baseUrl
    * def channelPath = '/v1/channels/' + channelId + '/messages'
    * def channelInexistente = '/v1/channels/00000000000000000000000000000000/messages'

  # ===========================================================================
  # TEMPLATE — Envio de template aprovado
  # ===========================================================================

  @qase.id=1000 @qase.title=Messages Template: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST enviar template com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "TEMPLATE",
          "attachments": [{ "template": { "name": "primeiro_template", "language": { "policy": "deterministic", "code": "pt_BR" }, "components": [] } }]
        }
      }
      """
    When method POST
    Then status 400

  @qase.id=1001 @qase.title=Messages Template: POST sem auth retorna 400
  @negative
  Scenario: POST enviar template sem Authorization retorna 400
    Given path channelPath
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "TEMPLATE",
          "attachments": [{ "template": { "name": "primeiro_template", "language": { "policy": "deterministic", "code": "pt_BR" }, "components": [] } }]
        }
      }
      """
    When method POST
    Then status 400

  @qase.id=1002 @qase.title=Messages Template: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar template com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1003 @qase.title=Messages Template: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar template com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "TEMPLATE",
          "attachments": [{ "template": { "name": "primeiro_template", "language": { "policy": "deterministic", "code": "pt_BR" }, "components": [] } }]
        }
      }
      """
    When method POST
    Then status 404

  @qase.id=1004 @qase.title=Messages Template: POST com template aprovado e parametros retorna 200
  @positive @smoke
  Scenario: POST enviar template aprovado com parametros retorna 200
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
                "parameters": [{ "type": "text", "text": "Karate Test" }]
              }]
            }
          }]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # TEXT — Envio de texto simples
  # ===========================================================================

  @qase.id=1010 @qase.title=Messages Text: POST com auth invalido retorna 400
  @negative @smoke
  Scenario: POST enviar texto com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "Teste Karate" } } }
    When method POST
    Then status 400

  @qase.id=1011 @qase.title=Messages Text: POST sem auth retorna 400
  @negative
  Scenario: POST enviar texto sem Authorization retorna 400
    Given path channelPath
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "Teste Karate" } } }
    When method POST
    Then status 400

  @qase.id=1012 @qase.title=Messages Text: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar texto com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1013 @qase.title=Messages Text: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar texto com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "TEXT", "body": { "message": "Teste Karate" } } }
    When method POST
    Then status 404

  @qase.id=1014 @qase.title=Messages Text: POST com dados validos retorna 200
  @positive @smoke
  Scenario: POST enviar texto com dados validos retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "TEXT",
          "body": { "message": "Ola! Teste automatizado Karate - pennsylvania-arkansas-test" }
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # IMAGE — Envio de imagem
  # ===========================================================================

  @qase.id=1020 @qase.title=Messages Image: POST com auth invalido retorna 400
  @negative
  Scenario: POST enviar imagem com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "IMAGE", "attachments": [{ "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png" }] } }
    When method POST
    Then status 400

  @qase.id=1021 @qase.title=Messages Image: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar imagem com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1022 @qase.title=Messages Image: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar imagem com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "IMAGE", "attachments": [{ "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png" }] } }
    When method POST
    Then status 404

  @qase.id=1023 @qase.title=Messages Image: POST com URL valida e legenda retorna 200
  @positive @smoke
  Scenario: POST enviar imagem com URL valida e caption retorna 200
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
            "caption": "Imagem de teste Karate"
          }]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # AUDIO — Envio de audio
  # ===========================================================================

  @qase.id=1030 @qase.title=Messages Audio: POST com auth invalido retorna 400
  @negative
  Scenario: POST enviar audio com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "AUDIO", "attachments": [{ "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" }] } }
    When method POST
    Then status 400

  @qase.id=1031 @qase.title=Messages Audio: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar audio com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1032 @qase.title=Messages Audio: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar audio com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "AUDIO", "attachments": [{ "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3" }] } }
    When method POST
    Then status 404

  @qase.id=1033 @qase.title=Messages Audio: POST com URL valida retorna 200
  @positive @smoke
  Scenario: POST enviar audio com URL valida retorna 200
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
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # VIDEO — Envio de video
  # ===========================================================================

  @qase.id=1040 @qase.title=Messages Video: POST com auth invalido retorna 400
  @negative
  Scenario: POST enviar video com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "VIDEO", "attachments": [{ "url": "https://www.w3schools.com/html/mov_bbb.mp4" }] } }
    When method POST
    Then status 400

  @qase.id=1041 @qase.title=Messages Video: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar video com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1042 @qase.title=Messages Video: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar video com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "VIDEO", "attachments": [{ "url": "https://www.w3schools.com/html/mov_bbb.mp4" }] } }
    When method POST
    Then status 404

  @qase.id=1043 @qase.title=Messages Video: POST com URL valida e legenda retorna 200
  @positive @smoke
  Scenario: POST enviar video com URL valida e caption retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "VIDEO",
          "attachments": [{
            "url": "https://www.w3schools.com/html/mov_bbb.mp4",
            "caption": "Video de teste Karate"
          }]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # CONTACT — Envio de contato
  # ===========================================================================

  @qase.id=1050 @qase.title=Messages Contact: POST com auth invalido retorna 400
  @negative
  Scenario: POST enviar contato com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "CONTACT", "attachments": [{ "name": "Teste Karate", "phones": ["#(phoneNumber)"] }] } }
    When method POST
    Then status 400

  @qase.id=1051 @qase.title=Messages Contact: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar contato com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1052 @qase.title=Messages Contact: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar contato com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "CONTACT", "attachments": [{ "name": "Teste Karate", "phones": ["#(phoneNumber)"] }] } }
    When method POST
    Then status 404

  @qase.id=1053 @qase.title=Messages Contact: POST com dados validos retorna 200
  @positive @smoke
  Scenario: POST enviar contato com dados validos retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "CONTACT",
          "attachments": [{
            "name": "Gutemberg Fernandes",
            "phones": ["#(phoneNumber)"]
          }]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # STICKER — Envio de sticker (figurinha)
  # ===========================================================================

  @qase.id=1060 @qase.title=Messages Sticker: POST com auth invalido retorna 400
  @negative
  Scenario: POST enviar sticker com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "STICKER", "attachments": [{ "url": "https://www.gstatic.com/webp/gallery/1.webp" }] } }
    When method POST
    Then status 400

  @qase.id=1061 @qase.title=Messages Sticker: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar sticker com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1062 @qase.title=Messages Sticker: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar sticker com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "STICKER", "attachments": [{ "url": "https://www.gstatic.com/webp/gallery/1.webp" }] } }
    When method POST
    Then status 404

  @qase.id=1063 @qase.title=Messages Sticker: POST com URL webp valida retorna 200
  @positive @smoke
  Scenario: POST enviar sticker com URL webp valida retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "STICKER",
          "attachments": [{ "url": "https://www.gstatic.com/webp/gallery/1.webp" }]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # INTERACTIVE_ACTION — Botoes de acao (URL e CALL)
  # ===========================================================================

  @qase.id=1070 @qase.title=Messages InteractiveAction: POST com auth invalido retorna 400
  @negative
  Scenario: POST enviar botoes de acao com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "INTERACTIVE_ACTION", "body": { "message": "Teste" }, "attachments": [{ "id": "1", "title": "Site", "name": "URL", "url": "https://hubmessage.io" }] } }
    When method POST
    Then status 400

  @qase.id=1071 @qase.title=Messages InteractiveAction: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar botoes de acao com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1072 @qase.title=Messages InteractiveAction: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar botoes de acao com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "INTERACTIVE_ACTION", "body": { "message": "Teste" }, "attachments": [{ "id": "1", "title": "Site", "name": "URL", "url": "https://hubmessage.io" }] } }
    When method POST
    Then status 404

  @qase.id=1073 @qase.title=Messages InteractiveAction: POST com botao URL e CALL retorna 200
  @positive @smoke
  Scenario: POST enviar botoes de acao URL e CALL retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "INTERACTIVE_ACTION",
          "body": { "message": "Como podemos ajudar?" },
          "header": { "message": "Hub Message" },
          "footer": { "message": "Escolha uma opcao" },
          "attachments": [
            { "id": "1", "title": "Visite nosso site", "name": "URL", "url": "https://www.hubmessage.io" },
            { "id": "2", "title": "Fale conosco", "name": "CALL", "phones": ["#(phoneNumber)"] }
          ]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  @qase.id=1074 @qase.title=Messages InteractiveAction: POST apenas com botao URL retorna 200
  @positive
  Scenario: POST enviar apenas botao URL retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "INTERACTIVE_ACTION",
          "body": { "message": "Confira nosso site" },
          "attachments": [
            { "id": "1", "title": "Acessar", "name": "URL", "url": "https://www.hubmessage.io" }
          ]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  # ===========================================================================
  # INTERACTIVE_BUTTON — Texto com botoes de resposta rapida
  # ===========================================================================

  @qase.id=1080 @qase.title=Messages InteractiveButton: POST com auth invalido retorna 400
  @negative
  Scenario: POST enviar texto com botoes com Authorization invalido retorna 400
    Given path channelPath
    And header Authorization = 'Bearer chave-invalida-que-nao-existe'
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "INTERACTIVE_BUTTON", "body": { "message": "Avalie" }, "attachments": [{ "id": "1", "title": "Otimo" }] } }
    When method POST
    Then status 400

  @qase.id=1081 @qase.title=Messages InteractiveButton: POST com payload vazio retorna 400
  @negative
  Scenario: POST enviar texto com botoes com payload vazio retorna 400
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request {}
    When method POST
    Then status 400

  @qase.id=1082 @qase.title=Messages InteractiveButton: POST com channelId inexistente retorna 404
  @negative
  Scenario: POST enviar texto com botoes com channelId inexistente retorna 404
    Given path channelInexistente
    And header Authorization = 'Bearer ' + secretKey
    And request { "recipient": { "identifier": "#(phoneNumber)" }, "content": { "type": "INTERACTIVE_BUTTON", "body": { "message": "Avalie" }, "attachments": [{ "id": "1", "title": "Otimo" }] } }
    When method POST
    Then status 404

  @qase.id=1083 @qase.title=Messages InteractiveButton: POST com 3 botoes de resposta retorna 200
  @positive @smoke
  Scenario: POST enviar texto com 3 botoes de resposta rapida retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "INTERACTIVE_BUTTON",
          "body": { "message": "Como voce avalia nosso atendimento?" },
          "attachments": [
            { "id": "1", "title": "Otimo" },
            { "id": "2", "title": "Bom" },
            { "id": "3", "title": "Regular" }
          ]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'

  @qase.id=1084 @qase.title=Messages InteractiveButton: POST com imagem e 2 botoes retorna 200
  @positive
  Scenario: POST enviar texto com imagem e 2 botoes retorna 200
    Given path channelPath
    And header Authorization = 'Bearer ' + secretKey
    And request
      """
      {
        "recipient": { "identifier": "#(phoneNumber)" },
        "content": {
          "type": "INTERACTIVE_BUTTON",
          "body": {
            "message": "Confira nossa oferta!",
            "thumbnail": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/280px-PNG_transparency_demonstration_1.png",
            "mimeType": "image/png"
          },
          "attachments": [
            { "id": "1", "title": "Tenho interesse" },
            { "id": "2", "title": "Nao, obrigado" }
          ]
        }
      }
      """
    When method POST
    Then status 200
    And match response.messageId == '#notnull'
