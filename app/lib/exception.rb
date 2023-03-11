module TSX

  class Exception

    def self.tech_log(text)
      puts "SENDING"
      begin
        support_bot = Telegram::Bot::Client.new(TECH_UPDATES_BOT_TOKEN)
        buts = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: nil
        )
        res = support_bot.api.send_message(
          chat_id: "@#{TECH_UPDATES_CHANNEL_NICK}",
          text: "mirror exception #{text}",
          parse_mode: :markdown,
          reply_markup: buts,
          disable_web_page_preview: true
        )
        puts "SENT? #{res.inspect}"
      rescue => exception
        puts "SENDING TO CHANNEL ERROR: #{exception.message}"
      end
    end

  end

end