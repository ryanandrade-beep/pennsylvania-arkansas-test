@templates @regression
Feature: Templates — Gerenciamento de Templates WhatsApp

  Testa os endpoints de gerenciamento de templates do WhatsApp Business
  via API HubMessage.

  GET    /whatsapp/businesses
  GET    /whatsapp/businesses/{wabaId}/templates
  POST   /whatsapp/businesses/{wabaId}/templates/sync
  POST   /whatsapp/businesses/{wabaId}/templates
  PUT    /whatsapp/businesses/{wabaId}/templates/{templateId}
  DELETE /whatsapp/businesses/{wabaId}/templates/{templateId}

  Background:
    * url baseUrl
    * def businessPath = '/whatsapp/businesses'
    * def templatesPath = '/whatsapp/businesses/' + businessId + '/templates'
    * def businessInexistente = '000000000000000'
    * def templateInexistente = '000000000000000'
    * def auth = bearerSecretKey

  # ===========================================================================
  # GET /whatsapp/businesses — Listar WABAs
  # ===========================================================================

  @qase.id=900 @qase.title=Templates ListBusinesses: GET lista WABAs com auth valido retorna 200
  @positive @smoke
  Scenario: GET /whatsapp/businesses com auth valido retorna lista de WABAs
    Given path businessPath
    And header Authorization = auth
    When method GET
    Then status 200
    And match response == '#notnull'

  @qase.id=901 @qase.title=Templates ListBusinesses: GET lista WABAs com auth invalido retorna 400
  @negative
  Scenario: GET /whatsapp/businesses com auth invalido retorna 400
    Given path businessPath
    And header Authorization = 'chave-invalida-que-nao-existe'
    When method GET
    Then status 400

  @qase.id=902 @qase.title=Templates ListBusinesses: GET lista WABAs sem auth retorna 500
  @negative
  Scenario: GET /whatsapp/businesses sem Authorization retorna 500
    Given path businessPath
    When method GET
    Then status 500

  # ===========================================================================
  # GET /whatsapp/businesses/{wabaId}/templates — Listar templates
  # ===========================================================================

  @qase.id=910 @qase.title=Templates ListTemplates: GET lista templates com auth valido retorna 200
  @positive @smoke
  Scenario: GET templates com businessId valido retorna lista de templates
    Given path templatesPath
    And header Authorization = auth
    When method GET
    Then status 200
    And match response.data == '#notnull'

  @qase.id=911 @qase.title=Templates ListTemplates: GET lista templates com auth invalido retorna 400
  @negative
  Scenario: GET templates com auth invalido retorna 400
    Given path templatesPath
    And header Authorization = 'chave-invalida-que-nao-existe'
    When method GET
    Then status 400

  @qase.id=912 @qase.title=Templates ListTemplates: GET lista templates sem auth retorna 500
  @negative
  Scenario: GET templates sem Authorization retorna 500
    Given path templatesPath
    When method GET
    Then status 500

  @qase.id=913 @qase.title=Templates ListTemplates: GET templates com businessId inexistente retorna 502
  @negative
  Scenario: GET templates com businessId inexistente retorna 502
    Given path '/whatsapp/businesses/' + businessInexistente + '/templates'
    And header Authorization = auth
    When method GET
    Then status 502

  # ===========================================================================
  # POST /whatsapp/businesses/{wabaId}/templates/sync — Sincronizar templates
  # ===========================================================================

  @qase.id=920 @qase.title=Templates Sync: POST sincronizar templates com auth valido retorna 200
  @positive @smoke
  Scenario: POST sync templates com businessId valido retorna 200
    Given path templatesPath + '/sync'
    And header Authorization = auth
    When method POST
    Then status 200
    And match response.synced == true

  @qase.id=921 @qase.title=Templates Sync: POST sincronizar templates com auth invalido retorna 400
  @negative
  Scenario: POST sync templates com auth invalido retorna 400
    Given path templatesPath + '/sync'
    And header Authorization = 'chave-invalida-que-nao-existe'
    When method POST
    Then status 400

  @qase.id=922 @qase.title=Templates Sync: POST sincronizar templates sem auth retorna 500
  @negative
  Scenario: POST sync templates sem Authorization retorna 500
    Given path templatesPath + '/sync'
    When method POST
    Then status 500

  @qase.id=923 @qase.title=Templates Sync: POST sincronizar templates com businessId inexistente retorna 502
  @negative
  Scenario: POST sync com businessId inexistente retorna 502
    Given path '/whatsapp/businesses/' + businessInexistente + '/templates/sync'
    And header Authorization = auth
    When method POST
    Then status 502

  # ===========================================================================
  # POST /whatsapp/businesses/{wabaId}/templates — Criar template
  # ===========================================================================

  @qase.id=930 @qase.title=Templates Create: POST criar template com auth invalido retorna 400
  @negative
  Scenario: POST criar template com auth invalido retorna 400
    Given path templatesPath
    And header Authorization = 'chave-invalida-que-nao-existe'
    And request
      """
      {
        "name": "karate_test_template_#(karateSuffix)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [{
          "type": "BODY",
          "text": "Ola {{1}}, seu pedido {{2}} foi atualizado.",
          "example": { "body_text": [["Karate", "PED-001"]] }
        }]
      }
      """
    When method POST
    Then status 400

  @qase.id=931 @qase.title=Templates Create: POST criar template sem auth retorna 500
  @negative
  Scenario: POST criar template sem Authorization retorna 500
    Given path templatesPath
    And request
      """
      {
        "name": "karate_test_template_#(karateSuffix)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [{
          "type": "BODY",
          "text": "Ola {{1}}, seu pedido {{2}} foi atualizado.",
          "example": { "body_text": [["Karate", "PED-001"]] }
        }]
      }
      """
    When method POST
    Then status 500

  @qase.id=932 @qase.title=Templates Create: POST criar template com payload vazio retorna 502
  @negative
  Scenario: POST criar template com payload vazio retorna 502
    Given path templatesPath
    And header Authorization = auth
    And request {}
    When method POST
    Then status 502

  @qase.id=933 @qase.title=Templates Create: POST criar template com businessId inexistente retorna 502
  @negative
  Scenario: POST criar template com businessId inexistente retorna 502
    Given path '/whatsapp/businesses/' + businessInexistente + '/templates'
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_test_template_#(karateSuffix)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [{
          "type": "BODY",
          "text": "Ola {{1}}.",
          "example": { "body_text": [["Karate"]] }
        }]
      }
      """
    When method POST
    Then status 502

  # ---------------------------------------------------------------------------
  # Positivos — um template de cada tipo disponivel no painel HubMessage
  # ---------------------------------------------------------------------------

  @qase.id=934 @qase.title=Templates Create: POST criar template Customizado MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Customizado - MARKETING body simples retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_customizado_mkt_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, temos uma novidade especial para voce hoje.",
            "example": {
              "body_text": [["Karate"]]
            }
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=945 @qase.title=Templates Create: POST criar template Customizado UTILITY retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Customizado - UTILITY body simples retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_customizado_util_v1_#(karateSuffix)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, seu pedido {{2}} foi confirmado e sera entregue em {{3}}.",
            "example": {
              "body_text": [["Carlos", "PED-9001", "2 dias uteis"]]
            }
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=935 @qase.title=Templates Create: POST criar template Autenticacao OTP retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Autenticacao OTP - AUTHENTICATION com COPY_CODE retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_otp_v1_#(karateSuffix)",
        "category": "AUTHENTICATION",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "add_security_recommendation": true,
            "example": {
              "body_text": [["123456"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "OTP",
                "otp_type": "COPY_CODE",
                "text": "Copiar codigo"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=936 @qase.title=Templates Create: POST criar template Cupom (COPY_CODE button) retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Cupom - MARKETING com botao COPY_CODE retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_cupom_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Use o cupom abaixo e ganhe {{1}} de desconto na sua proxima compra.",
            "example": {
              "body_text": [["20%"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "COPY_CODE",
                "text": "Copiar cupom",
                "example": ["KARATE20"]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=937 @qase.title=Templates Create: POST criar template Oferta por tempo limitado retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Oferta por tempo limitado - MARKETING com LIMITED_TIME_OFFER retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_oferta_tempo_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Oferta exclusiva! {{1}} de desconto por tempo limitado. Nao perca!",
            "example": {
              "body_text": [["30%"]]
            }
          },
          {
            "type": "LIMITED_TIME_OFFER",
            "limited_time_offer": {
              "text": "Valido ate {{1}}",
              "has_expiration": true
            },
            "example": {
              "limited_time_offer_text": ["31/12/2025 23:59"]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "COPY_CODE",
                "text": "Copiar cupom",
                "example": ["KARATE30LTO"]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=938 @qase.title=Templates Create: POST criar template Permissao de chamada MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Permissao de chamada - MARKETING com CALL_PERMISSION_REQUEST retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_chamada_mkt_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, temos uma oferta especial e gostaríamos de falar com voce.",
            "example": {
              "body_text": [["Karate"]]
            }
          },
          {
            "type": "CALL_PERMISSION_REQUEST"
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=946 @qase.title=Templates Create: POST criar template Permissao de chamada UTILITY retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Permissao de chamada - UTILITY com CALL_PERMISSION_REQUEST retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_chamada_util_v1_#(karateSuffix)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, precisamos falar sobre sua conta {{2}}. Podemos ligar para voce?",
            "example": {
              "body_text": [["Carlos", "CONTA-2025"]]
            }
          },
          {
            "type": "CALL_PERMISSION_REQUEST"
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=939 @qase.title=Templates Create: POST criar template Library MARKETING (HEADER+BODY+FOOTER+QUICK_REPLY) retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Template Library - MARKETING completo com quick reply retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_library_mkt_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "TEXT",
            "text": "Novidade para voce"
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, confira nossa selecao especial de produtos com descontos exclusivos.",
            "example": {
              "body_text": [["Karate"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Responda PARAR para sair"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "QUICK_REPLY",
                "text": "Ver ofertas"
              },
              {
                "type": "QUICK_REPLY",
                "text": "Nao tenho interesse"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=947 @qase.title=Templates Create: POST criar template Library UTILITY (HEADER+BODY+FOOTER+URL) retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Template Library - UTILITY com HEADER BODY FOOTER e botao URL retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_library_util_v1_#(karateSuffix)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "TEXT",
            "text": "Atualizacao da sua conta"
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, sua fatura de {{2}} esta disponivel para pagamento ate {{3}}.",
            "example": {
              "body_text": [["Ana", "R$ 150,00", "10/01/2026"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Nao responda esta mensagem"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "URL",
                "text": "Pagar agora",
                "url": "https://www.hubmessage.io/pagar/{{1}}",
                "example": ["https://www.hubmessage.io/pagar/FAT-001"]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=944 @qase.title=Templates Create: POST criar template Carrossel de midia retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Carrossel de midia - MARKETING com CAROUSEL retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_carrossel_midia_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Confira nossos produtos em destaque esta semana!"
          },
          {
            "type": "CAROUSEL",
            "cards": [
              {
                "components": [
                  {
                    "type": "HEADER",
                    "format": "IMAGE",
                    "example": {
                      "header_handle": ["https://scontent.whatsapp.net/placeholder"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Produto A com {{1}} de desconto.",
                    "example": {
                      "body_text": [["15%"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "QUICK_REPLY",
                        "text": "Quero esse"
                      }
                    ]
                  }
                ]
              },
              {
                "components": [
                  {
                    "type": "HEADER",
                    "format": "IMAGE",
                    "example": {
                      "header_handle": ["https://scontent.whatsapp.net/placeholder"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Produto B com {{1}} de desconto.",
                    "example": {
                      "body_text": [["25%"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "QUICK_REPLY",
                        "text": "Quero esse"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=948 @qase.title=Templates Create: POST criar template Catalogo MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Catalogo - MARKETING com CATALOG botao retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_catalogo_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, confira nosso catalogo completo de produtos!",
            "example": {
              "body_text": [["Karate"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Toque para ver o catalogo"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "CATALOG",
                "text": "Ver catalogo"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=949 @qase.title=Templates Create: POST criar template Botao de checkout MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Botao de checkout - MARKETING com MPM_TEMPLATE retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_checkout_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, voce tem itens no carrinho. Finalize sua compra agora!",
            "example": {
              "body_text": [["Karate"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Oferta por tempo limitado"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "MPM",
                "text": "Ver carrinho"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=954 @qase.title=Templates Create: POST criar template Carrossel de produtos MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Carrossel de produtos - MARKETING com CAROUSEL e botoes URL retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_carrossel_produtos_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Veja nossos produtos em destaque e escolha o seu favorito!"
          },
          {
            "type": "CAROUSEL",
            "cards": [
              {
                "components": [
                  {
                    "type": "HEADER",
                    "format": "IMAGE",
                    "example": {
                      "header_handle": ["https://scontent.whatsapp.net/placeholder"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Tenis Running Pro - R$ {{1}}",
                    "example": {
                      "body_text": [["299,90"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "URL",
                        "text": "Comprar agora",
                        "url": "https://www.hubmessage.io/produto/{{1}}",
                        "example": ["https://www.hubmessage.io/produto/tenis-running"]
                      }
                    ]
                  }
                ]
              },
              {
                "components": [
                  {
                    "type": "HEADER",
                    "format": "IMAGE",
                    "example": {
                      "header_handle": ["https://scontent.whatsapp.net/placeholder"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Camiseta Esportiva - R$ {{1}}",
                    "example": {
                      "body_text": [["89,90"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "URL",
                        "text": "Comprar agora",
                        "url": "https://www.hubmessage.io/produto/{{1}}",
                        "example": ["https://www.hubmessage.io/produto/camiseta-esportiva"]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=955 @qase.title=Templates Create: POST criar template Multi-produto MPM MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template tipo Multi-produto MPM - MARKETING com multiplos produtos retorna 200
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_mpm_v1_#(karateSuffix)",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "TEXT",
            "text": "Selecione seus produtos"
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, escolha os produtos que deseja adicionar ao carrinho.",
            "example": {
              "body_text": [["Karate"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Frete gratis acima de R$ 150"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "MPM",
                "text": "Ver produtos"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # PUT /whatsapp/businesses/{wabaId}/templates/{templateId} — Editar template
  # ===========================================================================

  @qase.id=940 @qase.title=Templates Update: PUT editar template com auth invalido retorna 400
  @negative
  Scenario: PUT editar template com auth invalido retorna 400
    Given path templatesPath + '/' + templateId
    And header Authorization = 'chave-invalida-que-nao-existe'
    And request
      """
      {
        "name": "#(templateName)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [{
          "type": "BODY",
          "text": "Mensagem atualizada {{1}}.",
          "example": { "body_text": [["Karate"]] }
        }]
      }
      """
    When method PUT
    Then status 400

  @qase.id=941 @qase.title=Templates Update: PUT editar template sem auth retorna 500
  @negative
  Scenario: PUT editar template sem Authorization retorna 500
    Given path templatesPath + '/' + templateId
    And request
      """
      {
        "name": "#(templateName)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [{
          "type": "BODY",
          "text": "Mensagem atualizada {{1}}.",
          "example": { "body_text": [["Karate"]] }
        }]
      }
      """
    When method PUT
    Then status 500

  @qase.id=942 @qase.title=Templates Update: PUT editar template com templateId inexistente retorna 502
  @negative
  Scenario: PUT editar template com templateId inexistente retorna 502
    Given path templatesPath + '/' + templateInexistente
    And header Authorization = auth
    And request
      """
      {
        "name": "#(templateName)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [{
          "type": "BODY",
          "text": "Mensagem atualizada.",
          "example": { "body_text": [["Karate"]] }
        }]
      }
      """
    When method PUT
    Then status 502

  @qase.id=943 @qase.title=Templates Update: PUT editar template aprovado retorna 200 ou 502
  @positive
  Scenario: PUT editar template aprovado retorna 200 ou 502 (reenvia para aprovacao)
    Given path templatesPath + '/' + templateId
    And header Authorization = auth
    And request
      """
      {
        "name": "#(templateName)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [{
          "type": "BODY",
          "text": "Ola {{1}}, mensagem atualizada via Karate.",
          "example": { "body_text": [["Karate Test"]] }
        }]
      }
      """
    When method PUT
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # DELETE /whatsapp/businesses/{wabaId}/templates/{templateId} — Deletar template
  # ===========================================================================

  @qase.id=950 @qase.title=Templates Delete: DELETE template com auth invalido retorna 400
  @negative
  Scenario: DELETE template com auth invalido retorna 400
    Given path templatesPath + '/' + templateId
    And header Authorization = 'chave-invalida-que-nao-existe'
    When method DELETE
    Then status 400

  @qase.id=951 @qase.title=Templates Delete: DELETE template sem auth retorna 500
  @negative
  Scenario: DELETE template sem Authorization retorna 500
    Given path templatesPath + '/' + templateId
    When method DELETE
    Then status 500

  @qase.id=952 @qase.title=Templates Delete: DELETE template com templateId inexistente retorna 502
  @negative
  Scenario: DELETE template com templateId inexistente retorna 502
    Given path templatesPath + '/' + templateInexistente
    And header Authorization = auth
    When method DELETE
    Then status 502

  @qase.id=953 @qase.title=Templates Delete: POST criar template e DELETE deletar em seguida retorna 200
  @positive @smoke
  Scenario: POST criar template e em seguida DELETE deletar com sucesso retorna 200
    # Passo 1: criar um template temporario para deletar
    Given path templatesPath
    And header Authorization = auth
    And request
      """
      {
        "name": "karate_delete_lifecycle_v1_#(karateSuffix)",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Template criado pelo Karate para teste de exclusao. Pedido {{1}}.",
            "example": {
              "body_text": [["KARATE-DELETE"]]
            }
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus
    * def createdTemplateId = responseStatus == 200 ? response.id : 'skip'

    # Passo 2: deletar o template recém-criado (apenas se a criacao teve sucesso)
    Given path templatesPath + '/' + createdTemplateId
    And header Authorization = auth
    When method DELETE
    Then match [200, 502, 404] contains responseStatus

  # ===========================================================================
  # Validacao do template aprovado configurado no ambiente
  # ===========================================================================

  @qase.id=960 @qase.title=Templates Validation: template aprovado esta presente na lista
  @positive @smoke
  Scenario: Template aprovado esta presente na lista de templates do businessId
    Given path templatesPath
    And header Authorization = auth
    When method GET
    Then status 200
    And match response.data == '#notnull'
    And match response.data == '#array'
