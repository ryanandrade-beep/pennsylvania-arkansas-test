function fn() {

  // ── Ambiente ────────────────────────────────────────────────────────────────
  var env = karate.env || 'staging';
  karate.log('[karate-config] ambiente:', env);

  // ── Helper: lê system property (-D) primeiro, depois env var, depois default ──
  function envOrDefault(key, defaultValue) {
    // System property tem prioridade (passado via -DKEY=value no Maven)
    var sysProp = java.lang.System.getProperty(key);
    if (sysProp !== null && sysProp !== '' && sysProp.indexOf('${') !== 0) return sysProp;
    // Variavel de ambiente do OS (exportada no shell ou pelo Surefire)
    var envVar = java.lang.System.getenv(key);
    if (envVar !== null && envVar !== '') return envVar;
    return defaultValue;
  }

  // ── URLs base por ambiente ───────────────────────────────────────────────────
  var baseUrls = {
    staging:    'https://api.staging.hubmessage.io',
    production: 'https://api.hubmessage.io',
    local:      'http://localhost:8080'
  };

  var baseUrl           = envOrDefault('BASE_URL',            baseUrls[env]);
  var conwayZapiUrl     = envOrDefault('CONWAY_ZAPI_URL',     baseUrl);
  var conwayTelegramUrl = envOrDefault('CONWAY_TELEGRAM_URL', baseUrl);
  var conwayMetaUrl     = envOrDefault('CONWAY_META_URL',     baseUrl);
  var barlingUrl        = envOrDefault('BARLING_URL',         baseUrl);
  var newportUrl        = envOrDefault('NEWPORT_URL',         baseUrl);

  // ── Credenciais ─────────────────────────────────────────────────────────────
  var secretKey           = envOrDefault('SECRET_KEY',            'sk_live_CONFIGURE_NO_ENV');
  var publicKey           = envOrDefault('PUBLIC_KEY',            'pk_live_CONFIGURE_NO_ENV');
  var enterpriseSecretKey = envOrDefault('ENTERPRISE_SECRET_KEY', secretKey);

  // ── Credenciais Meta / WhatsApp ─────────────────────────────────────────────
  var metaToken  = envOrDefault('META_TOKEN',  'CONFIGURE_NO_ENV');
  var catalogId  = envOrDefault('CATALOG_ID',  'CONFIGURE_NO_ENV');

  // ── IDs de recursos ──────────────────────────────────────────────────────────
  var channelId         = envOrDefault('CHANNEL_ID',          'CONFIGURE_NO_ENV');
  var zapiChannelId     = envOrDefault('ZAPI_CHANNEL_ID',     channelId);
  var telegramChannelId = envOrDefault('TELEGRAM_CHANNEL_ID', channelId);
  var metaChannelId     = envOrDefault('META_CHANNEL_ID',     channelId);
  var trialChannelId    = envOrDefault('TRIAL_CHANNEL_ID',    channelId);
  var phoneNumber       = envOrDefault('PHONE_NUMBER',        '5511999999999');
  var messageId         = envOrDefault('MESSAGE_ID',          'CONFIGURE_NO_ENV');
  var telegramBotToken  = envOrDefault('TELEGRAM_BOT_TOKEN',  'CONFIGURE_NO_ENV');
  var businessId        = envOrDefault('BUSINESS_ID',         'CONFIGURE_NO_ENV');
  var templateId        = envOrDefault('TEMPLATE_ID',         'CONFIGURE_NO_ENV');
  var templateName      = envOrDefault('TEMPLATE_NAME',       'teste_1');

  // ── Variaveis derivadas ──────────────────────────────────────────────────────
  var bearerSecretKey = 'Bearer ' + secretKey;

  // ── Configuração global do Karate ────────────────────────────────────────────
  var config = {
    env:                  env,

    // URLs
    baseUrl:              baseUrl,
    conwayZapiUrl:        conwayZapiUrl,
    conwayTelegramUrl:    conwayTelegramUrl,
    conwayMetaUrl:        conwayMetaUrl,
    barlingUrl:           barlingUrl,
    newportUrl:           newportUrl,

    // Credenciais
    secretKey:            secretKey,
    publicKey:            publicKey,
    enterpriseSecretKey:  enterpriseSecretKey,
    bearerSecretKey:      bearerSecretKey,

    // Credenciais Meta / WhatsApp
    metaToken:            metaToken,
    catalogId:            catalogId,

    // IDs de recursos
    channelId:            channelId,
    zapiChannelId:        zapiChannelId,
    telegramChannelId:    telegramChannelId,
    metaChannelId:        metaChannelId,
    trialChannelId:       trialChannelId,
    phoneNumber:          phoneNumber,
    messageId:            messageId,
    telegramBotToken:     telegramBotToken,
    businessId:           businessId,
    templateId:           templateId,
    templateName:         templateName,

    // Constantes de teste
    ID_INEXISTENTE:       '00000000-0000-0000-0000-000000000000',
    CHANNEL_INEXISTENTE:  '00000000000000000000000000000000'
  };

  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout',    15000);

  return config;
}
