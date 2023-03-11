ROOT = "#{File.dirname(__FILE__)}/.."
$stdout.sync = true
RESERVE_INTERVAL = 30
SUPPORT_BOT = "market_smile_support_bot"
MASTER_BOT = "master_smile_bot"
SUPPOT_BOT_TOKEN = "5798617420:AAFiL87nNnc-Z7suDHhpEn9mGlFnnhJDWr0"
BLOG_NICKNAME = "market_smile_blog"
TECH_UPDATES_BOT_TOKEN = "5407993833:AAEKTtsuzAhsk-WP8veOoM1URa_9jPFL178"
TECH_UPDATES_CHANNEL_NICK = "sml_tech_updates"
NGROK_DOMAIN = 'pdo.ngrok.io'
NASHOBMEN_DOMAIN = 'nashobmen.ngrok.io'
ACTUAL_DOMAIN = ENV['production'] == 'yes' ? 'nashobmen.herokuapp.com' : NGROK_DOMAIN
ACTUAL_BOT_DOMAIN = ENV['production'] == 'yes' ? 'nashobmen.herokuapp.com' : NGROK_DOMAIN
API_URL = ENV['production'] == 'yes' ? 'nashobmen.herokuapp.com' : NASHOBMEN_DOMAIN
TOKEN_SALT = "fuck you salt"
TOKEN_ALPHABET = 'ABCDEFGHKLMNO1234567890'
I18n.load_path << "#{ROOT}/locales/ru.yml" << "#{ROOT}/locales/date/ru.yml"
I18n.load_path << "#{ROOT}/locales/en.yml" << "#{ROOT}/locales/date/en.yml"
I18n.backend.load_translations
I18n.locale = :ru