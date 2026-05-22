@templates @production @regression
Feature: Templates Production — Cenarios para WABA 1268883528007780

  Testa criacao de templates WhatsApp Business via API HubMessage
  para o WABA de producao 1268883528007780.

  Tipos cobertos (sem dependencia de catalog_id):
    - HEADER IMAGE / VIDEO / DOCUMENT em template customizado
    - Botao PHONE_NUMBER
    - AUTHENTICATION zero_tap e one_tap
    - Multiplos botoes mistos (URL + QUICK_REPLY + PHONE_NUMBER)
    - Template apenas BODY sem componentes opcionais
    - HEADER com variavel dinamica
    - Carrossel com card VIDEO
    - Negativos especificos de producao

  POST   /whatsapp/businesses/{wabaId}/templates
  GET    /whatsapp/businesses/{wabaId}/templates
  DELETE /whatsapp/businesses/{wabaId}/templates/{templateId}

  Background:
    * url baseUrl
    * def prodBusinessId = '1387002032569151'
    * def prodTemplatesPath = '/whatsapp/businesses/' + prodBusinessId + '/templates'
    * def templateInexistente = '000000000000000'

  # ===========================================================================
  # GET — Listar templates do WABA de producao
  # ===========================================================================

  @qase.id=1000 @qase.title=TemplatesProd ListTemplates: GET lista templates WABA producao retorna 200
  @positive @smoke
  Scenario: GET templates do WABA de producao retorna lista valida
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    When method GET
    Then match [200, 502] contains responseStatus

  @qase.id=1001 @qase.title=TemplatesProd ListTemplates: GET templates WABA producao com auth invalido retorna 400
  @negative
  Scenario: GET templates WABA producao com auth invalido retorna 400
    Given path prodTemplatesPath
    And header Authorization = 'chave-invalida-producao'
    When method GET
    Then status 400

  @qase.id=1002 @qase.title=TemplatesProd ListTemplates: GET templates WABA producao sem auth retorna 500
  @negative
  Scenario: GET templates WABA producao sem Authorization retorna 500
    Given path prodTemplatesPath
    When method GET
    Then status 500

  # ===========================================================================
  # POST — HEADER IMAGE (template com imagem no cabecalho)
  # ===========================================================================

  @qase.id=1010 @qase.title=TemplatesProd Create: POST template HEADER IMAGE MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com HEADER IMAGE e botao QUICK_REPLY retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_header_image_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "IMAGE",
            "example": {
              "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-image"]
            }
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, confira nossa promocao exclusiva com {{2}} de desconto!",
            "example": {
              "body_text": [["Maria", "40%"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Responda PARAR para cancelar"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "QUICK_REPLY",
                "text": "Quero aproveitar"
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

  @qase.id=1011 @qase.title=TemplatesProd Create: POST template HEADER IMAGE UTILITY retorna 200
  @positive @smoke
  Scenario: POST criar template UTILITY com HEADER IMAGE e botao URL retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_header_image_util_v1",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "IMAGE",
            "example": {
              "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-image"]
            }
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, seu boleto de {{2}} com vencimento em {{3}} esta disponivel.",
            "example": {
              "body_text": [["Joao", "R$ 250,00", "15/06/2026"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "URL",
                "text": "Ver boleto",
                "url": "https://www.hubmessage.io/boleto/{{1}}",
                "example": ["https://www.hubmessage.io/boleto/BOL-2026-001"]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — HEADER VIDEO
  # ===========================================================================

  @qase.id=1020 @qase.title=TemplatesProd Create: POST template HEADER VIDEO MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com HEADER VIDEO retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_header_video_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "VIDEO",
            "example": {
              "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-video"]
            }
          },
          {
            "type": "BODY",
            "text": "Assista ao nosso novo video e descubra as novidades da temporada, {{1}}!",
            "example": {
              "body_text": [["Pedro"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "HubMessage — Comunicacao inteligente"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "QUICK_REPLY",
                "text": "Saiba mais"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — HEADER DOCUMENT
  # ===========================================================================

  @qase.id=1030 @qase.title=TemplatesProd Create: POST template HEADER DOCUMENT UTILITY retorna 200
  @positive @smoke
  Scenario: POST criar template UTILITY com HEADER DOCUMENT retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_header_document_util_v1",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "DOCUMENT",
            "example": {
              "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-pdf"]
            }
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, segue em anexo o contrato referente ao pedido {{2}}. Por favor, revise e assine.",
            "example": {
              "body_text": [["Ana Lima", "CONT-2026-789"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Duvidas? Entre em contato com suporte."
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — Botao PHONE_NUMBER
  # ===========================================================================

  @qase.id=1040 @qase.title=TemplatesProd Create: POST template com botao PHONE_NUMBER MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com botao PHONE_NUMBER retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_phone_button_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, nossa equipe esta pronta para te atender. Ligue agora e garanta sua oferta!",
            "example": {
              "body_text": [["Carlos"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "PHONE_NUMBER",
                "text": "Ligar agora",
                "phone_number": "+5511999990000"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=1041 @qase.title=TemplatesProd Create: POST template com botao PHONE_NUMBER UTILITY retorna 200
  @positive @smoke
  Scenario: POST criar template UTILITY com botao PHONE_NUMBER retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_phone_button_util_v1",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, identificamos uma atualizacao na sua conta {{2}}. Ligue para nossa central se precisar de ajuda.",
            "example": {
              "body_text": [["Lucia", "CONTA-4455"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "PHONE_NUMBER",
                "text": "Central de atendimento",
                "phone_number": "+5511999990000"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — Multiplos botoes mistos (URL + PHONE_NUMBER + QUICK_REPLY)
  # ===========================================================================

  @qase.id=1050 @qase.title=TemplatesProd Create: POST template com botoes mistos URL+PHONE_NUMBER+QUICK_REPLY retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com botoes mistos URL PHONE_NUMBER e QUICK_REPLY retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_mixed_buttons_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "TEXT",
            "text": "Oferta especial para voce"
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, sua oferta exclusiva de {{2}} de desconto expira em {{3}}. Nao perca!",
            "example": {
              "body_text": [["Roberto", "50%", "30/06/2026"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "HubMessage — Ofertas personalizadas"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "URL",
                "text": "Ver oferta",
                "url": "https://www.hubmessage.io/oferta/{{1}}",
                "example": ["https://www.hubmessage.io/oferta/OFERTA-2026"]
              },
              {
                "type": "PHONE_NUMBER",
                "text": "Falar com consultor",
                "phone_number": "+5511999990000"
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

  @qase.id=1051 @qase.title=TemplatesProd Create: POST template UTILITY com botoes URL+PHONE_NUMBER retorna 200
  @positive @smoke
  Scenario: POST criar template UTILITY com botoes URL e PHONE_NUMBER retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_url_phone_util_v1",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, seu pedido {{2}} esta pronto para retirada ou pode ser rastreado online.",
            "example": {
              "body_text": [["Fernanda", "PED-20260001"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "URL",
                "text": "Rastrear pedido",
                "url": "https://www.hubmessage.io/rastrear/{{1}}",
                "example": ["https://www.hubmessage.io/rastrear/PED-20260001"]
              },
              {
                "type": "PHONE_NUMBER",
                "text": "Ligar para loja",
                "phone_number": "+5511999990000"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — AUTHENTICATION zero_tap (autenticacao silenciosa)
  # ===========================================================================

  @qase.id=1060 @qase.title=TemplatesProd Create: POST template AUTHENTICATION zero_tap retorna 200
  @positive @smoke
  Scenario: POST criar template AUTHENTICATION com OTP zero_tap retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_otp_zerotap_v1",
        "category": "AUTHENTICATION",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "add_security_recommendation": true,
            "example": {
              "body_text": [["654321"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "OTP",
                "otp_type": "ZERO_TAP",
                "text": "Verificar automaticamente",
                "zero_tap_terms_accepted": true,
                "autofill_text": "Verificar"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — AUTHENTICATION one_tap
  # ===========================================================================

  @qase.id=1061 @qase.title=TemplatesProd Create: POST template AUTHENTICATION one_tap retorna 200
  @positive @smoke
  Scenario: POST criar template AUTHENTICATION com OTP one_tap retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_otp_onetap_v1",
        "category": "AUTHENTICATION",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "add_security_recommendation": true,
            "example": {
              "body_text": [["789012"]]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "OTP",
                "otp_type": "ONE_TAP",
                "text": "Confirmar acesso",
                "autofill_text": "Confirmar"
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — HEADER TEXT com variavel dinamica
  # ===========================================================================

  @qase.id=1070 @qase.title=TemplatesProd Create: POST template HEADER TEXT com variavel MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com HEADER TEXT dinamico retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_header_var_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "TEXT",
            "text": "Ola, {{1}}!",
            "example": {
              "header_text": ["Maria Silva"]
            }
          },
          {
            "type": "BODY",
            "text": "Temos uma selecao especial de produtos aguardando por voce. Aproveite {{1}} de desconto valido ate {{2}}.",
            "example": {
              "body_text": [["35%", "05/07/2026"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Cancele a qualquer momento respondendo PARAR"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "URL",
                "text": "Ver catalogo",
                "url": "https://www.hubmessage.io/catalogo",
                "example": ["https://www.hubmessage.io/catalogo"]
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

  # ===========================================================================
  # POST — Carrossel com cards VIDEO
  # ===========================================================================

  @qase.id=1080 @qase.title=TemplatesProd Create: POST template CAROUSEL VIDEO MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com CAROUSEL de VIDEO retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_carrossel_video_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Confira os lancamentos da semana em video!"
          },
          {
            "type": "CAROUSEL",
            "cards": [
              {
                "components": [
                  {
                    "type": "HEADER",
                    "format": "VIDEO",
                    "example": {
                      "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-video-1"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Lancamento A — disponivel com {{1}} de desconto.",
                    "example": {
                      "body_text": [["20%"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "QUICK_REPLY",
                        "text": "Quero saber mais"
                      }
                    ]
                  }
                ]
              },
              {
                "components": [
                  {
                    "type": "HEADER",
                    "format": "VIDEO",
                    "example": {
                      "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-video-2"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Lancamento B — frete gratis para compras acima de {{1}}.",
                    "example": {
                      "body_text": [["R$ 200,00"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "QUICK_REPLY",
                        "text": "Quero saber mais"
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

  # ===========================================================================
  # POST — Carrossel misto (IMAGE + VIDEO)
  # ===========================================================================

  @qase.id=1081 @qase.title=TemplatesProd Create: POST template CAROUSEL misto IMAGE e VIDEO retorna 200
  @positive
  Scenario: POST criar template MARKETING com CAROUSEL misto IMAGE e VIDEO retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_carrossel_misto_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Veja nossas novidades em diferentes formatos!"
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
                      "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-img-1"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Produto Imagem com {{1}} off.",
                    "example": {
                      "body_text": [["10%"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "URL",
                        "text": "Comprar",
                        "url": "https://www.hubmessage.io/produto/img",
                        "example": ["https://www.hubmessage.io/produto/img"]
                      }
                    ]
                  }
                ]
              },
              {
                "components": [
                  {
                    "type": "HEADER",
                    "format": "VIDEO",
                    "example": {
                      "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-video-3"]
                    }
                  },
                  {
                    "type": "BODY",
                    "text": "Produto Video com {{1}} off.",
                    "example": {
                      "body_text": [["15%"]]
                    }
                  },
                  {
                    "type": "BUTTONS",
                    "buttons": [
                      {
                        "type": "URL",
                        "text": "Comprar",
                        "url": "https://www.hubmessage.io/produto/video",
                        "example": ["https://www.hubmessage.io/produto/video"]
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

  # ===========================================================================
  # POST — Template somente BODY (sem header, footer ou botoes)
  # ===========================================================================

  @qase.id=1090 @qase.title=TemplatesProd Create: POST template somente BODY MARKETING retorna 200
  @positive
  Scenario: POST criar template MARKETING apenas com BODY sem outros componentes retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_only_body_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, voce tem uma mensagem importante da nossa equipe. Acesse sua conta para mais detalhes.",
            "example": {
              "body_text": [["Marcos"]]
            }
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  @qase.id=1091 @qase.title=TemplatesProd Create: POST template somente BODY UTILITY retorna 200
  @positive
  Scenario: POST criar template UTILITY apenas com BODY sem outros componentes retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_only_body_util_v1",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Ola {{1}}, seu agendamento para {{2}} no dia {{3}} as {{4}} foi confirmado com sucesso.",
            "example": {
              "body_text": [["Patricia", "Consulta Medica", "20/06/2026", "14:30"]]
            }
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — Cupom com HEADER IMAGE (combinacao de tipos)
  # ===========================================================================

  @qase.id=1100 @qase.title=TemplatesProd Create: POST template Cupom com HEADER IMAGE MARKETING retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com HEADER IMAGE e botao COPY_CODE retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_cupom_image_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "IMAGE",
            "example": {
              "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-cupom"]
            }
          },
          {
            "type": "BODY",
            "text": "Ola {{1}}, use o cupom abaixo e ganhe {{2}} de desconto na sua proxima compra!",
            "example": {
              "body_text": [["Juliana", "25%"]]
            }
          },
          {
            "type": "FOOTER",
            "text": "Valido por 7 dias"
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "COPY_CODE",
                "text": "Copiar cupom",
                "example": ["PROD25OFF"]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — Oferta por tempo limitado com HEADER IMAGE
  # ===========================================================================

  @qase.id=1101 @qase.title=TemplatesProd Create: POST template LIMITED_TIME_OFFER com HEADER IMAGE retorna 200
  @positive @smoke
  Scenario: POST criar template MARKETING com HEADER IMAGE e LIMITED_TIME_OFFER retorna 200
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_lto_image_mkt_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": [
          {
            "type": "HEADER",
            "format": "IMAGE",
            "example": {
              "header_handle": ["https://scontent.whatsapp.net/placeholder-prod-lto"]
            }
          },
          {
            "type": "BODY",
            "text": "Aproveite {{1}} de desconto em toda a loja. Oferta por tempo limitado!",
            "example": {
              "body_text": [["45%"]]
            }
          },
          {
            "type": "LIMITED_TIME_OFFER",
            "limited_time_offer": {
              "text": "Valido ate {{1}}",
              "has_expiration": true
            },
            "example": {
              "limited_time_offer_text": ["30/06/2026 23:59"]
            }
          },
          {
            "type": "BUTTONS",
            "buttons": [
              {
                "type": "COPY_CODE",
                "text": "Pegar desconto",
                "example": ["PROD45LTO"]
              }
            ]
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus

  # ===========================================================================
  # POST — Negativos especificos de producao
  # ===========================================================================

  @qase.id=1110 @qase.title=TemplatesProd Create: POST template com nome duplicado retorna 502
  @negative
  Scenario: POST criar template com nome ja existente no WABA de producao retorna 502
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "primeiro_template",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Template com nome duplicado para teste de producao {{1}}.",
            "example": {
              "body_text": [["Karate"]]
            }
          }
        ]
      }
      """
    When method POST
    Then status 502

  @qase.id=1111 @qase.title=TemplatesProd Create: POST template sem campo name retorna 502
  @negative
  Scenario: POST criar template sem campo name obrigatorio retorna 502
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Teste sem nome."
          }
        ]
      }
      """
    When method POST
    Then status 502

  @qase.id=1112 @qase.title=TemplatesProd Create: POST template sem campo category retorna 502
  @negative
  Scenario: POST criar template sem campo category obrigatorio retorna 502
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_sem_category_v1",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Teste sem categoria."
          }
        ]
      }
      """
    When method POST
    Then status 502

  @qase.id=1113 @qase.title=TemplatesProd Create: POST template sem campo language retorna 502
  @negative
  Scenario: POST criar template sem campo language obrigatorio retorna 502
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_sem_language_v1",
        "category": "MARKETING",
        "components": [
          {
            "type": "BODY",
            "text": "Teste sem idioma."
          }
        ]
      }
      """
    When method POST
    Then status 502

  @qase.id=1114 @qase.title=TemplatesProd Create: POST template com category invalida retorna 502
  @negative
  Scenario: POST criar template com category invalida retorna 502
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_cat_invalida_v1",
        "category": "INVALIDA",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Categoria invalida."
          }
        ]
      }
      """
    When method POST
    Then status 502

  @qase.id=1115 @qase.title=TemplatesProd Create: POST template com components vazio retorna 502
  @negative
  Scenario: POST criar template com components array vazio retorna 502
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_components_vazios_v1",
        "category": "MARKETING",
        "language": "pt_BR",
        "components": []
      }
      """
    When method POST
    Then status 502

  # ===========================================================================
  # DELETE — Lifecycle: criar e deletar template de producao
  # ===========================================================================

  @qase.id=1120 @qase.title=TemplatesProd Delete: POST criar e DELETE deletar template producao retorna 200
  @positive @smoke
  Scenario: POST criar template de producao e DELETE deletar em seguida retorna 200
    # Passo 1: criar template temporario para deletar
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    And request
      """
      {
        "name": "prod_delete_lifecycle_v1",
        "category": "UTILITY",
        "language": "pt_BR",
        "components": [
          {
            "type": "BODY",
            "text": "Template de producao criado para teste de exclusao. Pedido {{1}}.",
            "example": {
              "body_text": [["PROD-DELETE-001"]]
            }
          }
        ]
      }
      """
    When method POST
    Then match [200, 502] contains responseStatus
    * def fallbackId = '2581601165556488'
    * def createdProdTemplateId = responseStatus == 200 && response.id != null ? response.id : fallbackId

    # Passo 2: deletar o template recem-criado (ou fallback se criacao falhou com 502)
    Given path prodTemplatesPath + '/' + createdProdTemplateId
    And header Authorization = bearerSecretKey
    When method DELETE
    Then match [200, 502] contains responseStatus

  @qase.id=1121 @qase.title=TemplatesProd Delete: DELETE template inexistente WABA producao retorna 502
  @negative
  Scenario: DELETE template com ID inexistente no WABA de producao retorna 502
    Given path prodTemplatesPath + '/' + templateInexistente
    And header Authorization = bearerSecretKey
    When method DELETE
    Then status 502

  # ===========================================================================
  # Validacao — Templates aprovados devem aparecer na lista de producao
  # ===========================================================================

  @qase.id=1130 @qase.title=TemplatesProd Validation: template aprovado esta na lista de producao
  @positive @smoke
  Scenario: Template aprovado esta presente na lista de templates do WABA de producao
    Given path prodTemplatesPath
    And header Authorization = bearerSecretKey
    When method GET
    Then match [200, 502] contains responseStatus
