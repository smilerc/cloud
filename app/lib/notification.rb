module TSX

  class Notification

    def self.notify_owner(token, clients, text)
      clients.each do |owner|
        puts "Sending to bot: #{token}, client: #{owner}"
        begin
          owner_bot = Telegram::Bot::Client.new(token)
          sent = owner_bot.api.send_message(
            chat_id: owner,
            text: text,
            parse_mode: :markdown,
            disable_web_page_preview: true
          )
          puts "SENT? #{sent.inspect}"
        rescue => exception
          puts "SENDING TO CHANNEL ERROR: #{exception.message}"
        end
      end
    end

    def self.tech_log(text)
      Thread.new {
        begin
          support_bot = Telegram::Bot::Client.new(TECH_UPDATES_BOT_TOKEN)
          buts = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard: nil
          )
          res = support_bot.api.send_message(
            chat_id: "@#{TECH_UPDATES_CHANNEL_NICK}",
            text: "#{text}",
            parse_mode: :markdown,
            reply_markup: buts,
            disable_web_page_preview: true
          )
          puts "SENT? #{res.inspect}"
        rescue => exception
          puts "SENDING TO CHANNEL ERROR: #{exception.message}"
          # raise
        end
      }
    end


  end

end