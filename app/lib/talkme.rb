module TSX
  module Talkme

    class API

      def make_operator_online

        proxy_options = {
          uri: "http://200.26.186.184:1915",
          user: 'user91472',
          password: '42z9is'
        }

        conn = Faraday.new(url: 'https://lcab.talk-me.ru') do |faraday|
          faraday.request :url_encoded
          faraday.response :logger
          faraday.adapter Faraday.default_adapter
          faraday.proxy = proxy_options
        end

        headers = {
          'X-Token' => 'bjzfp14l9jczyf6pjau0so36p6uewl0xxoj88bzj0c4zwke8s4eke390ko5904qm',
          'Content-Type' => 'application/json'
        }

        # Define request body
        body = { operatorLogin: 'nashobmen_dmitry', status: 1 }

        # Send a POST request with headers and body
        response = conn.post do |req|
          req.url '/json/v1.0/chat/operator/setStatus'
          req.headers = headers
          req.body = body.to_json
        end

        puts response.body.inspect.colorize(:yellow)

      end


    end

  end
end
