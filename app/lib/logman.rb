module TSX
  module Logman

    class Logger < Logger

      def initialize
        super($stdout)
        self.formatter = proc do |severity, datetime, progname, msg|
          "#{severity}, #{datetime.to_time.strftime("%b %d")}: #{msg}\n"
        end
      end

    end

    class CronLogger < self::Logger
      attr_accessor :lines
      attr_accessor :bot

      def initialize
        super
        @lines = ''
      end

      def noise(text, color = :blue)
        print "#{@bot.tele}: ".colorize(:green) if !@bot.nil?
        puts "#{text.colorize(color)}"
      end

      def say(text)
        @lines << text << "\n"
        puts text
      end

      def _say(text)
        @lines << text
        print "#{text} ... "
      end

      def answer(text, color = :green)
        @lines << text << "\n"
        puts text.to_s.colorize(color)
      end

    end

  end
end
