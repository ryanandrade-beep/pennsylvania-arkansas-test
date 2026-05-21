#!/usr/bin/env python3
"""
create-qase-frontend-repository.py

Cria no Qase TMS toda a estrutura de suites e casos de teste de FRONTEND
para o HubMessage, no padrão BDD Gherkin (Given/When/Then).

Estrutura gerada:
  HubMessage Frontend
  ├── Autenticação
  │   ├── Login
  │   ├── Logout
  │   └── Recuperação de senha
  ├── Dashboard / Painel Principal
  ├── Canais
  │   ├── Listagem de canais
  │   ├── Criar canal
  │   ├── Editar canal
  │   └── Deletar canal
  ├── Instâncias Web (Z-API)
  │   ├── Listagem de instâncias
  │   ├── Conectar instância (QR Code)
  │   ├── Desconectar instância
  │   ├── Webhooks
  │   └── Configurações do WhatsApp
  ├── Instâncias Mobile
  ├── Mensagens
  │   ├── Enviar mensagem de texto
  │   ├── Enviar mensagem de mídia
  │   ├── Enviar mensagem de template
  │   └── Histórico de mensagens
  ├── Templates
  │   ├── Listagem de templates
  │   ├── Criar template
  │   ├── Editar template
  │   └── Deletar template
  ├── Contatos
  ├── Usuários
  │   ├── Listagem de usuários
  │   ├── Criar usuário
  │   ├── Editar usuário
  │   └── Permissões
  ├── Parceiros
  ├── Influenciadores
  ├── Dados da Conta
  ├── Segurança
  ├── Admin
  │   └── Configurações Beta
  ├── Contas Influencer
  │   ├── Painel
  │   ├── Afiliados
  │   └── Dados de recebimento
  ├── Contas White Label
  └── Relatórios / Auditoria

Uso:
  python3 create-qase-frontend-repository.py [--project PA] [--token <token>] [--dry-run]

Variáveis de ambiente aceitas:
  QASE_TESTOPS_API_TOKEN
  QASE_TESTOPS_PROJECT
"""

import os
import sys
import json
import time
import argparse
import urllib.request
import urllib.error

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
DEFAULT_PROJECT = os.environ.get("QASE_TESTOPS_PROJECT", "PA")
DEFAULT_TOKEN   = os.environ.get("QASE_TESTOPS_API_TOKEN", "")
QASE_BASE_URL   = "https://api.qase.io/v1"
RATE_LIMIT_SLEEP = 0.4   # segundos entre requests para evitar 429

# ---------------------------------------------------------------------------
# Helpers de API
# ---------------------------------------------------------------------------

def qase_request(method: str, path: str, token: str, body: dict | None = None) -> dict:
    url  = f"{QASE_BASE_URL}{path}"
    data = json.dumps(body).encode() if body else None
    req  = urllib.request.Request(url, data=data, method=method)
    req.add_header("Token", token)
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body_text = e.read().decode(errors="replace")
        print(f"  [HTTP {e.code}] {method} {path} → {body_text[:300]}")
        raise


def create_suite(project: str, token: str, title: str,
                 parent_id: int | None = None,
                 description: str = "",
                 preconditions: str = "",
                 dry_run: bool = False) -> int:
    """Cria uma suite e retorna o ID criado."""
    parent_info = f" (parent={parent_id})" if parent_id else ""
    print(f"    Suite: {title}{parent_info}")
    if dry_run:
        return -1
    payload = {"title": title}
    if description:
        payload["description"] = description
    if preconditions:
        payload["preconditions"] = preconditions
    if parent_id:
        payload["parent_id"] = parent_id
    time.sleep(RATE_LIMIT_SLEEP)
    result = qase_request("POST", f"/suite/{project}", token, payload)
    suite_id = result["result"]["id"]
    print(f"      → criada id={suite_id}")
    return suite_id


def create_case(project: str, token: str, suite_id: int, case_def: dict,
                dry_run: bool = False) -> int:
    """Cria um caso de teste Gherkin e retorna o ID."""
    title = case_def["title"]
    print(f"      Caso: {title}")
    if dry_run:
        return -1

    # monta steps no formato gherkin (value = string multiline)
    gherkin_text = case_def.get("gherkin", "")

    payload = {
        "title":        title,
        "description":  case_def.get("description", ""),
        "preconditions": case_def.get("preconditions", ""),
        "postconditions": case_def.get("postconditions", ""),
        "severity":     case_def.get("severity", 2),    # Normal
        "priority":     case_def.get("priority", 2),    # Medium
        "behavior":     case_def.get("behavior", 1),    # Positive
        "type":         case_def.get("type", 1),        # Functional
        "layer":        case_def.get("layer", 2),       # E2E
        "automation":   case_def.get("automation", 2),  # Manual
        "status":       case_def.get("status", 0),      # Actual
        "suite_id":     suite_id,
        "steps_type":   "gherkin",
        "steps":        [{"value": gherkin_text}] if gherkin_text else [],
    }
    time.sleep(RATE_LIMIT_SLEEP)
    result = qase_request("POST", f"/case/{project}", token, payload)
    case_id = result["result"]["id"]
    print(f"        → criado id={case_id}")
    return case_id


# ---------------------------------------------------------------------------
# Definição da estrutura completa de casos frontend HubMessage
# Formato: lista de (suite_title, parent_suite_title_or_None, [case_defs])
# ---------------------------------------------------------------------------

REPOSITORY = [

    # =========================================================================
    # 1. AUTENTICAÇÃO
    # =========================================================================
    {
        "suite": "Autenticação",
        "parent": "HubMessage Frontend",
        "cases": []
    },
    {
        "suite": "Login",
        "parent": "Autenticação",
        "cases": [
            {
                "title": "Login com credenciais válidas",
                "description": "Valida que um usuário com e-mail e senha corretos consegue acessar o sistema.",
                "preconditions": "Usuário cadastrado e ativo na plataforma.",
                "postconditions": "Usuário redirecionado para o painel principal.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário acessa a página de login do HubMessage\n"
                    "When o usuário preenche o campo 'E-mail' com um e-mail válido cadastrado\n"
                    "And preenche o campo 'Senha' com a senha correta\n"
                    "And clica no botão 'Entrar'\n"
                    "Then o usuário é redirecionado para o painel principal\n"
                    "And o menu lateral com as opções de navegação é exibido"
                ),
            },
            {
                "title": "Login com senha incorreta",
                "description": "Valida que o sistema exibe mensagem de erro ao tentar login com senha errada.",
                "preconditions": "Usuário cadastrado na plataforma.",
                "postconditions": "Usuário permanece na tela de login.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário acessa a página de login do HubMessage\n"
                    "When o usuário preenche o campo 'E-mail' com um e-mail válido\n"
                    "And preenche o campo 'Senha' com uma senha incorreta\n"
                    "And clica no botão 'Entrar'\n"
                    "Then uma mensagem de erro 'Credenciais inválidas' é exibida\n"
                    "And o usuário permanece na tela de login"
                ),
            },
            {
                "title": "Login com e-mail inválido",
                "description": "Valida mensagem de validação ao inserir e-mail com formato inválido.",
                "preconditions": "Nenhuma.",
                "postconditions": "Nenhuma.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário acessa a página de login do HubMessage\n"
                    "When o usuário preenche o campo 'E-mail' com 'email-invalido'\n"
                    "And preenche o campo 'Senha' com qualquer valor\n"
                    "And clica no botão 'Entrar'\n"
                    "Then uma mensagem de validação 'E-mail inválido' é exibida no campo e-mail"
                ),
            },
            {
                "title": "Login com campos obrigatórios vazios",
                "description": "Valida que o formulário bloqueia envio quando campos estão vazios.",
                "preconditions": "Nenhuma.",
                "postconditions": "Nenhuma.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário acessa a página de login do HubMessage\n"
                    "When o usuário deixa os campos 'E-mail' e 'Senha' em branco\n"
                    "And clica no botão 'Entrar'\n"
                    "Then mensagens de validação 'Campo obrigatório' são exibidas em ambos os campos\n"
                    "And o formulário não é submetido"
                ),
            },
        ],
    },
    {
        "suite": "Logout",
        "parent": "Autenticação",
        "cases": [
            {
                "title": "Logout com sucesso",
                "description": "Valida que o usuário consegue sair da plataforma com sucesso.",
                "preconditions": "Usuário autenticado na plataforma.",
                "postconditions": "Sessão encerrada; usuário redirecionado para tela de login.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário clica no menu do perfil no canto superior direito\n"
                    "And clica na opção 'Sair'\n"
                    "Then a sessão é encerrada\n"
                    "And o usuário é redirecionado para a tela de login"
                ),
            },
        ],
    },
    {
        "suite": "Recuperação de senha",
        "parent": "Autenticação",
        "cases": [
            {
                "title": "Solicitar recuperação de senha com e-mail válido",
                "description": "Valida que o fluxo de recuperação de senha envia e-mail ao usuário.",
                "preconditions": "Usuário cadastrado com e-mail válido.",
                "postconditions": "E-mail de recuperação enviado; mensagem de confirmação exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na tela de login do HubMessage\n"
                    "When o usuário clica em 'Esqueci minha senha'\n"
                    "And preenche o campo 'E-mail' com um e-mail cadastrado\n"
                    "And clica em 'Enviar'\n"
                    "Then uma mensagem de confirmação 'E-mail enviado com sucesso' é exibida"
                ),
            },
            {
                "title": "Solicitar recuperação de senha com e-mail não cadastrado",
                "description": "Valida comportamento ao tentar recuperar senha com e-mail inexistente.",
                "preconditions": "Nenhuma.",
                "postconditions": "Mensagem de erro ou mensagem genérica de segurança exibida.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está na tela de recuperação de senha\n"
                    "When o usuário preenche o campo 'E-mail' com um e-mail não cadastrado\n"
                    "And clica em 'Enviar'\n"
                    "Then uma mensagem informativa é exibida sem revelar se o e-mail existe"
                ),
            },
        ],
    },

    # =========================================================================
    # 2. DASHBOARD / PAINEL PRINCIPAL
    # =========================================================================
    {
        "suite": "Dashboard",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Exibição do painel principal após login",
                "description": "Valida que os elementos principais do dashboard são carregados corretamente.",
                "preconditions": "Usuário autenticado.",
                "postconditions": "Dashboard exibido com todos os widgets.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa o painel principal\n"
                    "Then os cards de resumo (canais ativos, mensagens enviadas, instâncias) são exibidos\n"
                    "And o menu lateral com todas as seções está visível\n"
                    "And nenhum erro de carregamento é apresentado"
                ),
            },
            {
                "title": "Navegação pelo menu lateral",
                "description": "Valida que todos os itens do menu lateral redirecionam corretamente.",
                "preconditions": "Usuário autenticado.",
                "postconditions": "Usuário redirecionado para a seção correta.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está no painel principal do HubMessage\n"
                    "When o usuário clica em cada item do menu lateral\n"
                    "Then cada item redireciona para a tela correspondente sem erros\n"
                    "And a URL da página muda conforme o item selecionado"
                ),
            },
        ],
    },

    # =========================================================================
    # 3. CANAIS
    # =========================================================================
    {
        "suite": "Canais",
        "parent": "HubMessage Frontend",
        "cases": []
    },
    {
        "suite": "Listagem de Canais",
        "parent": "Canais",
        "cases": [
            {
                "title": "Listar canais cadastrados",
                "description": "Valida que a tela exibe a lista de canais do workspace.",
                "preconditions": "Usuário autenticado com pelo menos um canal cadastrado.",
                "postconditions": "Lista de canais exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Canais'\n"
                    "Then uma lista com todos os canais cadastrados é exibida\n"
                    "And cada canal exibe nome, tipo e status de conexão"
                ),
            },
            {
                "title": "Exibir mensagem quando não há canais cadastrados",
                "description": "Valida estado vazio da listagem.",
                "preconditions": "Usuário autenticado sem canais cadastrados.",
                "postconditions": "Mensagem de estado vazio exibida.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está autenticado e não possui canais cadastrados\n"
                    "When o usuário acessa a seção 'Canais'\n"
                    "Then uma mensagem indicando 'Nenhum canal encontrado' é exibida\n"
                    "And um botão de 'Criar canal' é apresentado"
                ),
            },
            {
                "title": "Pesquisar canal por nome",
                "description": "Valida a funcionalidade de busca na listagem de canais.",
                "preconditions": "Usuário autenticado com canais cadastrados.",
                "postconditions": "Lista filtrada pelo termo buscado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na tela de listagem de canais\n"
                    "When o usuário digita o nome de um canal no campo de pesquisa\n"
                    "Then apenas os canais que contêm o termo pesquisado são exibidos"
                ),
            },
        ],
    },
    {
        "suite": "Criar Canal",
        "parent": "Canais",
        "cases": [
            {
                "title": "Criar canal WhatsApp (META) com dados válidos",
                "description": "Valida o fluxo completo de criação de um canal WhatsApp.",
                "preconditions": "Usuário autenticado com permissão de criação de canais.",
                "postconditions": "Canal criado e exibido na listagem.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na tela de listagem de canais\n"
                    "When o usuário clica em 'Criar canal'\n"
                    "And seleciona o tipo 'WhatsApp (META)'\n"
                    "And preenche o campo 'Nome' com um nome válido\n"
                    "And clica em 'Salvar'\n"
                    "Then o canal é criado com sucesso\n"
                    "And o novo canal aparece na listagem\n"
                    "And uma mensagem de sucesso é exibida"
                ),
            },
            {
                "title": "Criar canal sem preencher o campo nome",
                "description": "Valida validação do campo obrigatório nome.",
                "preconditions": "Usuário autenticado.",
                "postconditions": "Canal não é criado; erro de validação exibido.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está no formulário de criação de canal\n"
                    "When o usuário deixa o campo 'Nome' em branco\n"
                    "And clica em 'Salvar'\n"
                    "Then uma mensagem 'Campo obrigatório' é exibida no campo 'Nome'\n"
                    "And o canal não é criado"
                ),
            },
        ],
    },
    {
        "suite": "Editar Canal",
        "parent": "Canais",
        "cases": [
            {
                "title": "Editar nome de um canal existente",
                "description": "Valida que o nome de um canal pode ser atualizado.",
                "preconditions": "Usuário autenticado com pelo menos um canal cadastrado.",
                "postconditions": "Canal atualizado com o novo nome.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na listagem de canais\n"
                    "When o usuário clica em 'Editar' no canal desejado\n"
                    "And altera o campo 'Nome' para um novo valor válido\n"
                    "And clica em 'Salvar'\n"
                    "Then o canal é atualizado com o novo nome\n"
                    "And a listagem reflete o nome atualizado"
                ),
            },
        ],
    },
    {
        "suite": "Deletar Canal",
        "parent": "Canais",
        "cases": [
            {
                "title": "Deletar canal com confirmação",
                "description": "Valida o fluxo de exclusão de canal com modal de confirmação.",
                "preconditions": "Usuário autenticado com pelo menos um canal cadastrado.",
                "postconditions": "Canal removido da listagem.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na listagem de canais\n"
                    "When o usuário clica em 'Deletar' no canal desejado\n"
                    "And confirma a exclusão no modal de confirmação\n"
                    "Then o canal é removido da listagem\n"
                    "And uma mensagem de sucesso é exibida"
                ),
            },
            {
                "title": "Cancelar deleção de canal",
                "description": "Valida que cancelar no modal de confirmação não remove o canal.",
                "preconditions": "Usuário autenticado com pelo menos um canal cadastrado.",
                "postconditions": "Canal permanece na listagem.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na listagem de canais\n"
                    "When o usuário clica em 'Deletar' no canal desejado\n"
                    "And clica em 'Cancelar' no modal de confirmação\n"
                    "Then o modal é fechado\n"
                    "And o canal permanece na listagem"
                ),
            },
        ],
    },

    # =========================================================================
    # 4. INSTÂNCIAS WEB (Z-API)
    # =========================================================================
    {
        "suite": "Instâncias Web",
        "parent": "HubMessage Frontend",
        "cases": []
    },
    {
        "suite": "Listagem de Instâncias Web",
        "parent": "Instâncias Web",
        "cases": [
            {
                "title": "Listar instâncias web disponíveis",
                "description": "Valida que a tela exibe as instâncias web do workspace.",
                "preconditions": "Usuário autenticado com instâncias cadastradas.",
                "postconditions": "Lista de instâncias exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa 'Instâncias Web' no menu lateral\n"
                    "Then a lista de instâncias é exibida\n"
                    "And cada instância exibe nome, status de conexão e tipo"
                ),
            },
        ],
    },
    {
        "suite": "Conectar Instância (QR Code)",
        "parent": "Instâncias Web",
        "cases": [
            {
                "title": "Gerar QR Code para conectar instância",
                "description": "Valida que o QR Code é gerado ao tentar conectar uma instância desconectada.",
                "preconditions": "Instância existente e desconectada.",
                "postconditions": "QR Code exibido na tela.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na listagem de instâncias web\n"
                    "When o usuário clica em uma instância com status 'Desconectada'\n"
                    "And clica no botão 'Conectar'\n"
                    "Then um QR Code é gerado e exibido na tela\n"
                    "And uma instrução para escanear com o WhatsApp é apresentada"
                ),
            },
            {
                "title": "Instância fica conectada após escaneamento do QR Code",
                "description": "Valida que o status muda para 'Conectado' após scan bem-sucedido.",
                "preconditions": "QR Code gerado e exibido.",
                "postconditions": "Instância com status 'Conectado'.",
                "behavior": 1,
                "gherkin": (
                    "Given que o QR Code foi gerado para uma instância\n"
                    "When o usuário escaneia o QR Code com o WhatsApp\n"
                    "Then o status da instância muda para 'Conectado'\n"
                    "And o número de telefone associado é exibido\n"
                    "And uma notificação de sucesso é apresentada"
                ),
            },
        ],
    },
    {
        "suite": "Desconectar Instância",
        "parent": "Instâncias Web",
        "cases": [
            {
                "title": "Desconectar instância conectada",
                "description": "Valida o fluxo de desconexão de uma instância ativa.",
                "preconditions": "Instância conectada ao WhatsApp.",
                "postconditions": "Instância desconectada; status atualizado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está nos detalhes de uma instância conectada\n"
                    "When o usuário clica em 'Desconectar'\n"
                    "And confirma a ação no modal de confirmação\n"
                    "Then a instância é desconectada\n"
                    "And o status muda para 'Desconectado'"
                ),
            },
        ],
    },
    {
        "suite": "Webhooks",
        "parent": "Instâncias Web",
        "cases": [
            {
                "title": "Configurar URL de webhook na instância",
                "description": "Valida que é possível cadastrar uma URL de webhook válida.",
                "preconditions": "Usuário autenticado; instância existente.",
                "postconditions": "URL de webhook salva na instância.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na aba 'Webhooks' de uma instância web\n"
                    "When o usuário preenche o campo 'URL do webhook' com uma URL válida\n"
                    "And clica em 'Salvar'\n"
                    "Then a URL de webhook é salva com sucesso\n"
                    "And uma mensagem de confirmação é exibida"
                ),
            },
            {
                "title": "Configurar webhook com URL inválida",
                "description": "Valida mensagem de erro ao inserir URL inválida no campo de webhook.",
                "preconditions": "Usuário autenticado; instância existente.",
                "postconditions": "Webhook não salvo; erro de validação exibido.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está na aba 'Webhooks' de uma instância web\n"
                    "When o usuário preenche o campo 'URL do webhook' com 'url-invalida'\n"
                    "And clica em 'Salvar'\n"
                    "Then uma mensagem 'URL inválida' é exibida\n"
                    "And o webhook não é salvo"
                ),
            },
            {
                "title": "Ativar eventos de webhook (mensagens recebidas)",
                "description": "Valida que é possível ativar o evento de recebimento de mensagens no webhook.",
                "preconditions": "URL de webhook configurada.",
                "postconditions": "Evento 'Mensagens recebidas' ativado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na aba 'Webhooks' com uma URL configurada\n"
                    "When o usuário ativa o toggle 'Mensagens recebidas'\n"
                    "And clica em 'Salvar'\n"
                    "Then o evento 'Mensagens recebidas' fica habilitado\n"
                    "And a configuração é persistida"
                ),
            },
        ],
    },
    {
        "suite": "Configurações do WhatsApp",
        "parent": "Instâncias Web",
        "cases": [
            {
                "title": "Ativar rejeição automática de chamadas recebidas",
                "description": "Valida o funcionamento do switch 'Rejeitar chamadas automáticas'. Quando ativado, chamadas recebidas são rejeitadas automaticamente no número conectado.",
                "preconditions": "Instância conectada ao WhatsApp com permissão de edição nas configurações.",
                "postconditions": "Chamadas recebidas são automaticamente rejeitadas (se ativado).",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa 'Instâncias Web' e clica em uma instância conectada\n"
                    "And clica na aba 'Webhooks e configurações gerais'\n"
                    "And ativa o switch 'Rejeitar chamadas automáticas'\n"
                    "Then o switch fica ativo\n"
                    "And a configuração é salva com sucesso\n"
                    "And as chamadas recebidas passam a ser rejeitadas automaticamente"
                ),
            },
            {
                "title": "Desativar rejeição automática de chamadas recebidas",
                "description": "Valida que ao desativar o switch as chamadas voltam a ser recebidas normalmente.",
                "preconditions": "Switch 'Rejeitar chamadas automáticas' ativo.",
                "postconditions": "Switch desativado; chamadas recebidas normalmente.",
                "behavior": 1,
                "gherkin": (
                    "Given que o switch 'Rejeitar chamadas automáticas' está ativo na instância\n"
                    "When o usuário desativa o switch\n"
                    "Then o switch fica inativo\n"
                    "And a configuração é salva\n"
                    "And as chamadas voltam a ser recebidas normalmente"
                ),
            },
            {
                "title": "Configurar mensagem de resposta automática para chamadas rejeitadas",
                "description": "Valida que é possível definir uma mensagem enviada automaticamente ao rejeitar chamada.",
                "preconditions": "Switch 'Rejeitar chamadas automáticas' ativo.",
                "postconditions": "Mensagem de resposta configurada.",
                "behavior": 1,
                "gherkin": (
                    "Given que o switch 'Rejeitar chamadas automáticas' está ativo\n"
                    "When o usuário preenche o campo 'Mensagem de resposta' com um texto válido\n"
                    "And clica em 'Salvar'\n"
                    "Then a mensagem é salva\n"
                    "And será enviada automaticamente quando uma chamada for rejeitada"
                ),
            },
        ],
    },

    # =========================================================================
    # 5. INSTÂNCIAS MOBILE
    # =========================================================================
    {
        "suite": "Instâncias Mobile",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Listar instâncias mobile do workspace",
                "description": "Valida que as instâncias mobile são listadas corretamente.",
                "preconditions": "Usuário autenticado com instâncias mobile cadastradas.",
                "postconditions": "Lista de instâncias mobile exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa 'Instâncias Mobile' no menu lateral\n"
                    "Then a lista de instâncias mobile é exibida\n"
                    "And cada instância exibe nome, status e plataforma (Android/iOS)"
                ),
            },
            {
                "title": "Conectar instância mobile via pareamento",
                "description": "Valida o fluxo de pareamento de uma instância mobile.",
                "preconditions": "Instância mobile criada e desconectada.",
                "postconditions": "Instância conectada.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está nos detalhes de uma instância mobile desconectada\n"
                    "When o usuário clica em 'Conectar'\n"
                    "And segue as instruções de pareamento exibidas na tela\n"
                    "Then a instância é conectada com sucesso\n"
                    "And o status é atualizado para 'Conectado'"
                ),
            },
        ],
    },

    # =========================================================================
    # 6. MENSAGENS
    # =========================================================================
    {
        "suite": "Mensagens",
        "parent": "HubMessage Frontend",
        "cases": []
    },
    {
        "suite": "Enviar Mensagem de Texto",
        "parent": "Mensagens",
        "cases": [
            {
                "title": "Enviar mensagem de texto simples para um contato",
                "description": "Valida o envio de mensagem de texto via interface frontend.",
                "preconditions": "Usuário autenticado; canal conectado; número de destino válido.",
                "postconditions": "Mensagem enviada e confirmada na interface.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção 'Mensagens' do HubMessage\n"
                    "When o usuário seleciona um canal ativo\n"
                    "And preenche o campo 'Número de destino' com um número válido\n"
                    "And seleciona o tipo 'Texto'\n"
                    "And preenche o campo 'Mensagem' com um texto válido\n"
                    "And clica em 'Enviar'\n"
                    "Then a mensagem é enviada com sucesso\n"
                    "And o ID da mensagem é exibido na tela"
                ),
            },
            {
                "title": "Enviar mensagem de texto sem preencher o campo de destino",
                "description": "Valida validação do campo obrigatório número de destino.",
                "preconditions": "Usuário autenticado.",
                "postconditions": "Mensagem não enviada; erro de validação exibido.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está no formulário de envio de mensagem\n"
                    "When o usuário deixa o campo 'Número de destino' em branco\n"
                    "And preenche o campo 'Mensagem' com um texto\n"
                    "And clica em 'Enviar'\n"
                    "Then uma mensagem 'Campo obrigatório' é exibida no campo 'Número de destino'\n"
                    "And a mensagem não é enviada"
                ),
            },
        ],
    },
    {
        "suite": "Enviar Mensagem de Mídia",
        "parent": "Mensagens",
        "cases": [
            {
                "title": "Enviar mensagem com imagem",
                "description": "Valida o envio de uma mensagem com anexo de imagem.",
                "preconditions": "Canal conectado; arquivo de imagem válido disponível.",
                "postconditions": "Mensagem com imagem enviada com sucesso.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está no formulário de envio de mensagem\n"
                    "When o usuário seleciona um canal ativo\n"
                    "And seleciona o tipo 'Imagem'\n"
                    "And faz upload de uma imagem válida (JPEG/PNG)\n"
                    "And preenche o campo 'Número de destino'\n"
                    "And clica em 'Enviar'\n"
                    "Then a mensagem com imagem é enviada com sucesso\n"
                    "And o ID da mensagem é retornado"
                ),
            },
            {
                "title": "Enviar mensagem com vídeo",
                "description": "Valida envio de mensagem com anexo de vídeo.",
                "preconditions": "Canal conectado; arquivo de vídeo válido disponível.",
                "postconditions": "Mensagem com vídeo enviada.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está no formulário de envio de mensagem\n"
                    "When o usuário seleciona o tipo 'Vídeo'\n"
                    "And faz upload de um arquivo de vídeo válido (MP4)\n"
                    "And preenche o número de destino\n"
                    "And clica em 'Enviar'\n"
                    "Then a mensagem com vídeo é enviada com sucesso"
                ),
            },
            {
                "title": "Enviar mensagem com áudio",
                "description": "Valida envio de mensagem com arquivo de áudio.",
                "preconditions": "Canal conectado; arquivo de áudio válido.",
                "postconditions": "Mensagem com áudio enviada.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está no formulário de envio de mensagem\n"
                    "When o usuário seleciona o tipo 'Áudio'\n"
                    "And faz upload de um arquivo de áudio válido (OGG/MP3)\n"
                    "And preenche o número de destino\n"
                    "And clica em 'Enviar'\n"
                    "Then a mensagem com áudio é enviada com sucesso"
                ),
            },
            {
                "title": "Tentar enviar arquivo com formato não suportado",
                "description": "Valida que arquivos com extensão não suportada são rejeitados.",
                "preconditions": "Canal conectado.",
                "postconditions": "Arquivo rejeitado; erro exibido.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está no formulário de envio de mensagem com mídia\n"
                    "When o usuário tenta fazer upload de um arquivo com extensão '.exe'\n"
                    "Then uma mensagem de erro 'Formato de arquivo não suportado' é exibida\n"
                    "And o arquivo não é carregado"
                ),
            },
        ],
    },
    {
        "suite": "Enviar Mensagem de Template",
        "parent": "Mensagens",
        "cases": [
            {
                "title": "Enviar mensagem usando template aprovado",
                "description": "Valida o envio de mensagem usando um template de WhatsApp aprovado.",
                "preconditions": "Canal conectado; template aprovado disponível.",
                "postconditions": "Mensagem de template enviada com sucesso.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está no formulário de envio de mensagem\n"
                    "When o usuário seleciona o tipo 'Template'\n"
                    "And seleciona um template aprovado da lista\n"
                    "And preenche as variáveis do template (se houver)\n"
                    "And preenche o número de destino\n"
                    "And clica em 'Enviar'\n"
                    "Then a mensagem de template é enviada com sucesso\n"
                    "And o ID da mensagem é exibido"
                ),
            },
        ],
    },
    {
        "suite": "Histórico de Mensagens",
        "parent": "Mensagens",
        "cases": [
            {
                "title": "Visualizar histórico de mensagens enviadas",
                "description": "Valida que o histórico de mensagens é exibido corretamente.",
                "preconditions": "Mensagens enviadas anteriormente.",
                "postconditions": "Histórico exibido com paginação.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção de histórico de mensagens\n"
                    "When o usuário acessa o histórico de um canal ativo\n"
                    "Then as mensagens enviadas são listadas em ordem cronológica decrescente\n"
                    "And cada mensagem exibe status, tipo e data/hora de envio"
                ),
            },
        ],
    },

    # =========================================================================
    # 7. TEMPLATES
    # =========================================================================
    {
        "suite": "Templates",
        "parent": "HubMessage Frontend",
        "cases": []
    },
    {
        "suite": "Listagem de Templates",
        "parent": "Templates",
        "cases": [
            {
                "title": "Listar templates disponíveis",
                "description": "Valida que os templates do WABA são listados corretamente.",
                "preconditions": "Usuário autenticado com templates cadastrados.",
                "postconditions": "Lista de templates exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Templates'\n"
                    "Then a lista de templates é exibida\n"
                    "And cada template exibe nome, categoria, idioma e status de aprovação"
                ),
            },
            {
                "title": "Filtrar templates por status",
                "description": "Valida o filtro de templates por status de aprovação.",
                "preconditions": "Templates com diferentes status (aprovado, pendente, rejeitado).",
                "postconditions": "Lista filtrada pelo status selecionado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na listagem de templates\n"
                    "When o usuário aplica o filtro 'Status: Aprovado'\n"
                    "Then apenas templates com status 'Aprovado' são exibidos"
                ),
            },
        ],
    },
    {
        "suite": "Criar Template",
        "parent": "Templates",
        "cases": [
            {
                "title": "Criar template de marketing customizado",
                "description": "Valida criação de template MARKETING com corpo de texto.",
                "preconditions": "Usuário autenticado com permissão de gerenciamento de templates.",
                "postconditions": "Template criado e enviado para aprovação Meta.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção de criação de templates\n"
                    "When o usuário preenche o campo 'Nome' com um nome único\n"
                    "And seleciona a categoria 'Marketing'\n"
                    "And seleciona o idioma 'Português (BR)'\n"
                    "And preenche o corpo do template com texto válido\n"
                    "And clica em 'Criar template'\n"
                    "Then o template é criado com status 'Pendente de aprovação'\n"
                    "And o template aparece na listagem"
                ),
            },
            {
                "title": "Criar template com nome duplicado",
                "description": "Valida que não é possível criar dois templates com o mesmo nome.",
                "preconditions": "Template com o mesmo nome já existe.",
                "postconditions": "Template não criado; mensagem de erro exibida.",
                "behavior": 2,
                "gherkin": (
                    "Given que existe um template com o nome 'meu_template'\n"
                    "When o usuário tenta criar um novo template com o nome 'meu_template'\n"
                    "Then uma mensagem de erro indicando nome duplicado é exibida\n"
                    "And o template não é criado"
                ),
            },
            {
                "title": "Criar template com header de imagem",
                "description": "Valida criação de template com imagem no cabeçalho.",
                "preconditions": "Usuário autenticado; imagem válida disponível.",
                "postconditions": "Template com header de imagem criado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está no formulário de criação de templates\n"
                    "When o usuário seleciona 'Header: Imagem'\n"
                    "And faz upload de uma imagem válida\n"
                    "And preenche o corpo e rodapé do template\n"
                    "And clica em 'Criar template'\n"
                    "Then o template é criado com o header de imagem\n"
                    "And o status é 'Pendente de aprovação'"
                ),
            },
            {
                "title": "Criar template OTP de autenticação",
                "description": "Valida criação de template de autenticação com botão de cópia de código.",
                "preconditions": "Usuário autenticado.",
                "postconditions": "Template OTP criado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está no formulário de criação de templates\n"
                    "When o usuário seleciona a categoria 'Autenticação'\n"
                    "And seleciona o tipo de botão 'Copiar código OTP'\n"
                    "And preenche o código de segurança de exemplo\n"
                    "And clica em 'Criar template'\n"
                    "Then o template OTP é criado com sucesso\n"
                    "And o botão 'Copiar código' aparece no preview"
                ),
            },
        ],
    },
    {
        "suite": "Editar Template",
        "parent": "Templates",
        "cases": [
            {
                "title": "Editar corpo de template pendente",
                "description": "Valida que um template pendente pode ter seu corpo editado.",
                "preconditions": "Template com status 'Pendente' existente.",
                "postconditions": "Template atualizado e reenviado para aprovação.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na listagem de templates\n"
                    "When o usuário clica em 'Editar' em um template com status 'Pendente'\n"
                    "And altera o texto do corpo do template\n"
                    "And clica em 'Salvar'\n"
                    "Then o template é atualizado\n"
                    "And o status permanece 'Pendente de aprovação'"
                ),
            },
        ],
    },
    {
        "suite": "Deletar Template",
        "parent": "Templates",
        "cases": [
            {
                "title": "Deletar template com confirmação",
                "description": "Valida o fluxo de exclusão de template com confirmação.",
                "preconditions": "Template existente na listagem.",
                "postconditions": "Template removido da listagem.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na listagem de templates\n"
                    "When o usuário clica em 'Deletar' no template desejado\n"
                    "And confirma a exclusão no modal de confirmação\n"
                    "Then o template é removido da listagem\n"
                    "And uma mensagem de sucesso é exibida"
                ),
            },
        ],
    },

    # =========================================================================
    # 8. CONTATOS
    # =========================================================================
    {
        "suite": "Contatos",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Listar contatos do workspace",
                "description": "Valida exibição da lista de contatos.",
                "preconditions": "Usuário autenticado com contatos cadastrados.",
                "postconditions": "Lista de contatos exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Contatos'\n"
                    "Then a lista de contatos é exibida\n"
                    "And cada contato exibe nome e número de telefone"
                ),
            },
            {
                "title": "Pesquisar contato por nome ou número",
                "description": "Valida a busca de contatos pelo campo de pesquisa.",
                "preconditions": "Contatos cadastrados.",
                "postconditions": "Lista filtrada pelo termo buscado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na tela de contatos\n"
                    "When o usuário digita um nome ou número no campo de pesquisa\n"
                    "Then apenas os contatos que correspondem ao termo são exibidos"
                ),
            },
            {
                "title": "Verificar se número existe no WhatsApp",
                "description": "Valida a funcionalidade de verificação de número WhatsApp.",
                "preconditions": "Canal Z-API conectado.",
                "postconditions": "Resultado da verificação exibido.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção de contatos\n"
                    "When o usuário insere um número válido no campo 'Verificar número'\n"
                    "And clica em 'Verificar'\n"
                    "Then o sistema retorna se o número está registrado no WhatsApp\n"
                    "And exibe o resultado na tela"
                ),
            },
        ],
    },

    # =========================================================================
    # 9. USUÁRIOS
    # =========================================================================
    {
        "suite": "Usuários",
        "parent": "HubMessage Frontend",
        "cases": []
    },
    {
        "suite": "Listagem de Usuários",
        "parent": "Usuários",
        "cases": [
            {
                "title": "Listar usuários do workspace",
                "description": "Valida que a lista de usuários é exibida corretamente.",
                "preconditions": "Usuário admin autenticado.",
                "postconditions": "Lista de usuários exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário admin está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Usuários'\n"
                    "Then a lista de usuários do workspace é exibida\n"
                    "And cada usuário exibe nome, e-mail e função"
                ),
            },
        ],
    },
    {
        "suite": "Criar Usuário",
        "parent": "Usuários",
        "cases": [
            {
                "title": "Criar novo usuário com dados válidos",
                "description": "Valida o fluxo de criação de novo usuário.",
                "preconditions": "Usuário admin autenticado.",
                "postconditions": "Novo usuário criado e listado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o admin está na tela de usuários\n"
                    "When o admin clica em 'Novo usuário'\n"
                    "And preenche os campos 'Nome', 'E-mail' e seleciona uma função\n"
                    "And clica em 'Salvar'\n"
                    "Then o novo usuário é criado\n"
                    "And aparece na listagem de usuários\n"
                    "And um e-mail de convite é enviado ao novo usuário"
                ),
            },
            {
                "title": "Criar usuário com e-mail já cadastrado",
                "description": "Valida que não é possível criar usuário com e-mail duplicado.",
                "preconditions": "Usuário com o mesmo e-mail já existe.",
                "postconditions": "Usuário não criado; erro exibido.",
                "behavior": 2,
                "gherkin": (
                    "Given que o admin está no formulário de criação de usuário\n"
                    "When o admin preenche o campo 'E-mail' com um e-mail já cadastrado\n"
                    "And clica em 'Salvar'\n"
                    "Then uma mensagem 'E-mail já cadastrado' é exibida\n"
                    "And o usuário não é criado"
                ),
            },
        ],
    },
    {
        "suite": "Editar Usuário",
        "parent": "Usuários",
        "cases": [
            {
                "title": "Editar função de um usuário existente",
                "description": "Valida que a função de um usuário pode ser alterada.",
                "preconditions": "Usuário admin; usuário alvo existente.",
                "postconditions": "Função do usuário atualizada.",
                "behavior": 1,
                "gherkin": (
                    "Given que o admin está na listagem de usuários\n"
                    "When o admin clica em 'Editar' em um usuário\n"
                    "And altera a função do usuário\n"
                    "And clica em 'Salvar'\n"
                    "Then a função do usuário é atualizada\n"
                    "And a listagem reflete a nova função"
                ),
            },
        ],
    },
    {
        "suite": "Permissões",
        "parent": "Usuários",
        "cases": [
            {
                "title": "Usuário sem permissão não acessa área de admin",
                "description": "Valida que usuários sem role admin não podem acessar configurações administrativas.",
                "preconditions": "Usuário autenticado com role padrão (não admin).",
                "postconditions": "Acesso negado; mensagem de erro exibida.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está autenticado com a função 'Padrão'\n"
                    "When o usuário tenta acessar a área de 'Administração'\n"
                    "Then o acesso é negado\n"
                    "And uma mensagem 'Permissão insuficiente' é exibida"
                ),
            },
        ],
    },

    # =========================================================================
    # 10. PARCEIROS
    # =========================================================================
    {
        "suite": "Parceiros",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Listar parceiros cadastrados",
                "description": "Valida a exibição da lista de parceiros.",
                "preconditions": "Usuário autenticado com permissão de parceiros.",
                "postconditions": "Lista de parceiros exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Parceiros'\n"
                    "Then a lista de parceiros é exibida\n"
                    "And cada parceiro exibe nome, status e data de cadastro"
                ),
            },
            {
                "title": "Adicionar novo parceiro",
                "description": "Valida o fluxo de adição de um novo parceiro.",
                "preconditions": "Usuário admin autenticado.",
                "postconditions": "Parceiro adicionado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na tela de parceiros\n"
                    "When o usuário clica em 'Adicionar parceiro'\n"
                    "And preenche os dados do parceiro\n"
                    "And clica em 'Salvar'\n"
                    "Then o parceiro é adicionado com sucesso\n"
                    "And aparece na listagem"
                ),
            },
        ],
    },

    # =========================================================================
    # 11. INFLUENCIADORES
    # =========================================================================
    {
        "suite": "Influenciadores",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Listar influenciadores cadastrados",
                "description": "Valida a exibição da lista de influenciadores.",
                "preconditions": "Usuário autenticado com influenciadores cadastrados.",
                "postconditions": "Lista de influenciadores exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Influenciadores'\n"
                    "Then a lista de influenciadores é exibida\n"
                    "And cada influenciador exibe nome e link de afiliado"
                ),
            },
        ],
    },

    # =========================================================================
    # 12. DADOS DA CONTA
    # =========================================================================
    {
        "suite": "Dados da Conta",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Visualizar dados da conta",
                "description": "Valida que os dados da conta são exibidos corretamente.",
                "preconditions": "Usuário autenticado.",
                "postconditions": "Dados da conta exibidos.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Dados da conta'\n"
                    "Then os dados da conta são exibidos (nome, e-mail, plano)\n"
                    "And as informações de faturamento estão visíveis"
                ),
            },
            {
                "title": "Atualizar nome da conta",
                "description": "Valida que o nome da conta pode ser atualizado.",
                "preconditions": "Usuário admin autenticado.",
                "postconditions": "Nome da conta atualizado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção 'Dados da conta'\n"
                    "When o usuário altera o campo 'Nome da conta'\n"
                    "And clica em 'Salvar'\n"
                    "Then o nome da conta é atualizado\n"
                    "And a interface reflete o novo nome"
                ),
            },
        ],
    },

    # =========================================================================
    # 13. SEGURANÇA
    # =========================================================================
    {
        "suite": "Segurança",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Gerar nova chave de API (Secret Key)",
                "description": "Valida o fluxo de geração de nova chave de API.",
                "preconditions": "Usuário admin autenticado.",
                "postconditions": "Nova chave gerada e exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção 'Segurança'\n"
                    "When o usuário clica em 'Gerar nova chave'\n"
                    "And confirma a ação no modal de aviso\n"
                    "Then uma nova Secret Key é gerada\n"
                    "And a chave anterior é invalidada\n"
                    "And a nova chave é exibida uma única vez"
                ),
            },
            {
                "title": "Visualizar chave de API mascarada",
                "description": "Valida que a chave de API é exibida mascarada por segurança.",
                "preconditions": "Chave de API cadastrada.",
                "postconditions": "Chave exibida com máscara.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção 'Segurança'\n"
                    "When o usuário visualiza a Secret Key cadastrada\n"
                    "Then a chave é exibida de forma mascarada (ex: sk_live_****)\n"
                    "And há um botão para copiar ou revelar a chave"
                ),
            },
            {
                "title": "Ativar autenticação de dois fatores (2FA)",
                "description": "Valida o fluxo de ativação do 2FA.",
                "preconditions": "Usuário autenticado sem 2FA ativo.",
                "postconditions": "2FA ativado na conta.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção 'Segurança'\n"
                    "When o usuário clica em 'Ativar autenticação de dois fatores'\n"
                    "And escaneia o QR Code com um aplicativo autenticador\n"
                    "And insere o código gerado para confirmar\n"
                    "Then o 2FA é ativado com sucesso\n"
                    "And uma mensagem de confirmação é exibida"
                ),
            },
        ],
    },

    # =========================================================================
    # 14. ADMIN / CONFIGURAÇÕES BETA
    # =========================================================================
    {
        "suite": "Admin",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Acessar painel admin com conta autorizada",
                "description": "Valida que apenas contas com role admin acessam o painel admin.",
                "preconditions": "Conta com role admin autenticada.",
                "postconditions": "Painel admin exibido.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado com uma conta admin\n"
                    "When o usuário acessa a seção 'Admin'\n"
                    "Then o painel administrativo é exibido\n"
                    "And todas as opções de gerenciamento estão disponíveis"
                ),
            },
        ],
    },
    {
        "suite": "Configurações Beta",
        "parent": "Admin",
        "cases": [
            {
                "title": "Ativar funcionalidade beta no workspace",
                "description": "Valida que uma funcionalidade beta pode ser habilitada pelo admin.",
                "preconditions": "Admin autenticado; funcionalidade beta disponível.",
                "postconditions": "Funcionalidade beta ativada.",
                "behavior": 1,
                "gherkin": (
                    "Given que o admin está na seção 'Configurações Beta'\n"
                    "When o admin ativa o toggle de uma funcionalidade beta\n"
                    "And salva as configurações\n"
                    "Then a funcionalidade é habilitada no workspace\n"
                    "And o toggle permanece ativo após recarregar a página"
                ),
            },
        ],
    },

    # =========================================================================
    # 15. CONTAS INFLUENCER
    # =========================================================================
    {
        "suite": "Contas Influencer",
        "parent": "HubMessage Frontend",
        "cases": []
    },
    {
        "suite": "Painel Influencer",
        "parent": "Contas Influencer",
        "cases": [
            {
                "title": "Visualizar painel de conta influencer",
                "description": "Valida que o painel da conta influencer carrega corretamente.",
                "preconditions": "Conta influencer autenticada.",
                "postconditions": "Painel exibido com métricas.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado com uma conta influencer\n"
                    "When o usuário acessa o painel principal\n"
                    "Then o painel exibe métricas de indicações e ganhos\n"
                    "And o link de afiliado único é visível"
                ),
            },
        ],
    },
    {
        "suite": "Afiliados",
        "parent": "Contas Influencer",
        "cases": [
            {
                "title": "Listar afiliados indicados pelo influencer",
                "description": "Valida exibição da lista de afiliados.",
                "preconditions": "Conta influencer com afiliados cadastrados.",
                "postconditions": "Lista de afiliados exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o influencer está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Afiliados'\n"
                    "Then a lista de afiliados indicados é exibida\n"
                    "And cada afiliado exibe nome, data de cadastro e status"
                ),
            },
            {
                "title": "Assinar conta usando link de afiliado",
                "description": "Valida o fluxo de assinatura via link de afiliado.",
                "preconditions": "Link de afiliado válido.",
                "postconditions": "Conta criada e vinculada ao influencer.",
                "behavior": 1,
                "gherkin": (
                    "Given que um novo usuário acessa o link de afiliado do influencer\n"
                    "When o usuário realiza o cadastro e assinatura pela landing page\n"
                    "Then a nova conta é vinculada ao influencer\n"
                    "And o influencer visualiza o novo afiliado em sua lista"
                ),
            },
        ],
    },
    {
        "suite": "Dados de Recebimento",
        "parent": "Contas Influencer",
        "cases": [
            {
                "title": "Cadastrar dados bancários para recebimento",
                "description": "Valida o cadastro de dados bancários do influencer.",
                "preconditions": "Conta influencer autenticada.",
                "postconditions": "Dados bancários salvos.",
                "behavior": 1,
                "gherkin": (
                    "Given que o influencer está na seção 'Dados de recebimento'\n"
                    "When o influencer preenche os dados bancários (banco, agência, conta)\n"
                    "And clica em 'Salvar'\n"
                    "Then os dados são salvos com sucesso\n"
                    "And uma confirmação é exibida"
                ),
            },
            {
                "title": "Visualizar extrato de comissões",
                "description": "Valida que o extrato de comissões é exibido corretamente.",
                "preconditions": "Influencer com comissões geradas.",
                "postconditions": "Extrato exibido.",
                "behavior": 1,
                "gherkin": (
                    "Given que o influencer está na seção 'Dados de recebimento'\n"
                    "When o influencer acessa o extrato de comissões\n"
                    "Then o histórico de comissões é exibido por período\n"
                    "And o valor total pendente de pagamento é mostrado"
                ),
            },
        ],
    },

    # =========================================================================
    # 16. CONTAS WHITE LABEL
    # =========================================================================
    {
        "suite": "Contas White Label",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Listar contas white label",
                "description": "Valida a listagem de contas white label disponíveis.",
                "preconditions": "Usuário com permissão white label autenticado.",
                "postconditions": "Lista de contas white label exibida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado com permissão white label\n"
                    "When o usuário acessa a seção 'Contas White Label'\n"
                    "Then a lista de contas white label é exibida\n"
                    "And cada conta exibe nome, domínio e status"
                ),
            },
            {
                "title": "Configurar domínio personalizado para white label",
                "description": "Valida o cadastro de domínio personalizado em conta white label.",
                "preconditions": "Conta white label existente.",
                "postconditions": "Domínio configurado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está nos detalhes de uma conta white label\n"
                    "When o usuário insere um domínio válido no campo 'Domínio'\n"
                    "And clica em 'Salvar'\n"
                    "Then o domínio é configurado com sucesso\n"
                    "And as instruções de DNS são exibidas"
                ),
            },
        ],
    },

    # =========================================================================
    # 17. RELATÓRIOS / AUDITORIA
    # =========================================================================
    {
        "suite": "Relatórios e Auditoria",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Visualizar log de eventos de auditoria",
                "description": "Valida que o log de auditoria é exibido corretamente.",
                "preconditions": "Usuário admin autenticado; eventos de auditoria registrados.",
                "postconditions": "Log de auditoria exibido.",
                "behavior": 1,
                "gherkin": (
                    "Given que o admin está autenticado no HubMessage\n"
                    "When o admin acessa a seção 'Relatórios e Auditoria'\n"
                    "Then o log de eventos é exibido em ordem cronológica\n"
                    "And cada evento exibe ação, usuário responsável e data/hora"
                ),
            },
            {
                "title": "Filtrar log de auditoria por usuário",
                "description": "Valida o filtro de eventos de auditoria por usuário específico.",
                "preconditions": "Log de auditoria com eventos de múltiplos usuários.",
                "postconditions": "Log filtrado pelo usuário selecionado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o admin está na tela de log de auditoria\n"
                    "When o admin aplica o filtro 'Usuário' selecionando um usuário específico\n"
                    "Then apenas eventos realizados por esse usuário são exibidos"
                ),
            },
            {
                "title": "Filtrar log de auditoria por período",
                "description": "Valida o filtro por intervalo de datas.",
                "preconditions": "Eventos registrados em diferentes datas.",
                "postconditions": "Log filtrado pelo período selecionado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o admin está na tela de log de auditoria\n"
                    "When o admin define um intervalo de datas no filtro de período\n"
                    "Then apenas eventos dentro do período são exibidos"
                ),
            },
            {
                "title": "Exportar log de auditoria",
                "description": "Valida a exportação do log de auditoria em formato CSV.",
                "preconditions": "Eventos de auditoria disponíveis.",
                "postconditions": "Arquivo CSV baixado.",
                "behavior": 1,
                "gherkin": (
                    "Given que o admin está na tela de log de auditoria com eventos listados\n"
                    "When o admin clica em 'Exportar'\n"
                    "And seleciona o formato 'CSV'\n"
                    "Then o arquivo CSV é gerado e o download é iniciado\n"
                    "And o arquivo contém todos os eventos do período filtrado"
                ),
            },
        ],
    },

    # =========================================================================
    # 18. ASSINATURA E PLANOS
    # =========================================================================
    {
        "suite": "Assinatura e Planos",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Visualizar plano atual da conta",
                "description": "Valida que o plano contratado é exibido corretamente.",
                "preconditions": "Usuário autenticado.",
                "postconditions": "Plano atual exibido.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está autenticado no HubMessage\n"
                    "When o usuário acessa a seção 'Assinatura'\n"
                    "Then o plano atual é exibido com nome, valor e data de renovação\n"
                    "And os limites de uso (canais, mensagens) são visíveis"
                ),
            },
            {
                "title": "Fazer upgrade de plano",
                "description": "Valida o fluxo de upgrade para um plano superior.",
                "preconditions": "Usuário no plano básico.",
                "postconditions": "Plano atualizado; novo plano ativo.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário está na seção 'Assinatura'\n"
                    "When o usuário clica em 'Fazer upgrade'\n"
                    "And seleciona um plano superior\n"
                    "And confirma o pagamento\n"
                    "Then o plano é atualizado para o plano selecionado\n"
                    "And as novas funcionalidades ficam disponíveis imediatamente"
                ),
            },
            {
                "title": "Cancelar assinatura",
                "description": "Valida o fluxo de cancelamento da assinatura.",
                "preconditions": "Usuário com assinatura ativa.",
                "postconditions": "Assinatura cancelada ao final do período vigente.",
                "behavior": 2,
                "gherkin": (
                    "Given que o usuário está na seção 'Assinatura'\n"
                    "When o usuário clica em 'Cancelar assinatura'\n"
                    "And confirma o cancelamento no modal de aviso\n"
                    "Then a assinatura é marcada para cancelamento\n"
                    "And o acesso continua até o final do período pago\n"
                    "And uma confirmação de cancelamento é enviada por e-mail"
                ),
            },
        ],
    },

    # =========================================================================
    # 19. NOTIFICAÇÕES
    # =========================================================================
    {
        "suite": "Notificações",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Receber notificação de instância desconectada",
                "description": "Valida que o sistema notifica quando uma instância perde a conexão.",
                "preconditions": "Instância conectada ao WhatsApp.",
                "postconditions": "Notificação exibida na interface.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário tem uma instância conectada\n"
                    "When a instância perde a conexão com o WhatsApp\n"
                    "Then uma notificação de alerta é exibida no painel\n"
                    "And o status da instância é atualizado para 'Desconectada'"
                ),
            },
            {
                "title": "Marcar notificação como lida",
                "description": "Valida a funcionalidade de marcar notificações como lidas.",
                "preconditions": "Notificações não lidas disponíveis.",
                "postconditions": "Notificação marcada como lida.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário tem notificações não lidas no painel\n"
                    "When o usuário clica em uma notificação\n"
                    "Then a notificação é marcada como lida\n"
                    "And o contador de não lidas é decrementado"
                ),
            },
        ],
    },

    # =========================================================================
    # 20. RESPONSIVIDADE E ACESSIBILIDADE
    # =========================================================================
    {
        "suite": "Responsividade e Acessibilidade",
        "parent": "HubMessage Frontend",
        "cases": [
            {
                "title": "Interface responsiva em dispositivo mobile",
                "description": "Valida que o layout se adapta corretamente a telas menores.",
                "preconditions": "Navegador com viewport configurado para 375px de largura.",
                "postconditions": "Layout adaptado sem overflow horizontal.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário acessa o HubMessage em um dispositivo com tela de 375px\n"
                    "When o usuário navega pelas telas principais\n"
                    "Then o layout se adapta sem overflow horizontal\n"
                    "And o menu lateral é substituído por um menu hamburguer\n"
                    "And todos os botões e campos permanecem utilizáveis"
                ),
            },
            {
                "title": "Navegação por teclado (acessibilidade)",
                "description": "Valida que os elementos interativos são acessíveis via teclado.",
                "preconditions": "Navegador padrão.",
                "postconditions": "Todos os elementos focáveis acessíveis.",
                "behavior": 1,
                "gherkin": (
                    "Given que o usuário acessa a tela de login do HubMessage\n"
                    "When o usuário navega pelos campos usando a tecla Tab\n"
                    "Then o foco se move de forma lógica pelos campos do formulário\n"
                    "And o botão 'Entrar' pode ser acionado com a tecla Enter"
                ),
            },
        ],
    },
]


# ---------------------------------------------------------------------------
# Lógica principal
# ---------------------------------------------------------------------------

def build_suite_tree() -> dict[str, list[dict]]:
    """Organiza REPOSITORY por suite pai."""
    tree: dict[str, list[dict]] = {}
    for item in REPOSITORY:
        parent = item["parent"]
        if parent not in tree:
            tree[parent] = []
        tree[parent].append(item)
    return tree


def run(project: str, token: str, dry_run: bool):
    print(f"\n{'='*60}")
    print(f"  Qase Frontend Repository Creator — HubMessage")
    print(f"  Project : {project}")
    print(f"  Dry Run : {dry_run}")
    print(f"{'='*60}\n")

    # Mapeia: suite_title → id
    suite_ids: dict[str, int] = {}

    # 1. Criar a suite raiz
    root_title = "HubMessage Frontend"
    print(f"[1/2] Criando suites...")
    root_id = create_suite(project, token, root_title, dry_run=dry_run)
    suite_ids[root_title] = root_id

    # 2. Processar suites em ordem do REPOSITORY preservando dependências
    for item in REPOSITORY:
        title  = item["suite"]
        parent = item["parent"]

        if title in suite_ids:
            continue  # já criada

        parent_id = suite_ids.get(parent)
        if parent_id is None and parent != root_title:
            # Pai ainda não foi criado (não deveria acontecer nesta ordem)
            print(f"  [AVISO] Suite pai '{parent}' não encontrada para '{title}' — usando raiz")
            parent_id = root_id

        sid = create_suite(project, token, title, parent_id=parent_id, dry_run=dry_run)
        suite_ids[title] = sid

    # 3. Criar os casos de teste
    print(f"\n[2/2] Criando casos de teste...")
    total_cases = 0
    for item in REPOSITORY:
        cases = item.get("cases", [])
        if not cases:
            continue
        suite_title = item["suite"]
        suite_id    = suite_ids.get(suite_title, -1)
        print(f"\n  Suite: {suite_title} (id={suite_id})")
        for case_def in cases:
            create_case(project, token, suite_id, case_def, dry_run=dry_run)
            total_cases += 1

    print(f"\n{'='*60}")
    print(f"  Concluído!")
    print(f"  Suites criadas : {len(suite_ids)}")
    print(f"  Casos criados  : {total_cases}")
    if dry_run:
        print(f"  *** DRY RUN — nenhum dado foi enviado ao Qase ***")
    print(f"{'='*60}\n")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Cria repositório frontend BDD Gherkin no Qase TMS para o HubMessage."
    )
    parser.add_argument("--project", default=DEFAULT_PROJECT,
                        help=f"Código do projeto Qase (padrão: {DEFAULT_PROJECT})")
    parser.add_argument("--token",   default=DEFAULT_TOKEN,
                        help="Token da API do Qase (ou defina QASE_TESTOPS_API_TOKEN)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Imprime a estrutura sem enviar ao Qase")
    args = parser.parse_args()

    if not args.token and not args.dry_run:
        print("ERRO: Token da API do Qase não informado.")
        print("  Use --token <seu_token> ou defina a variável QASE_TESTOPS_API_TOKEN")
        sys.exit(1)

    run(args.project, args.token, args.dry_run)


if __name__ == "__main__":
    main()
