module TSX
  class PublicController < TSX::ApplicationController

    get '/' do
      status 503
      'Internal Server Error'
      # @contacts = JSON.parse(Faraday.get("https://#{API_DOMAIN}/api/get_support").body)
      # haml :'web/index', layout: :'layouts/layout', :escape_html => false
    end

    get '/uid/:uid' do
      headers \
"Content-Type" => "text/plain; charset=utf-8"
      begin
        link = TSX::Encode.from_enc(params[:uid])
      rescue OpenSSL::Cipher::CipherError => ex
        status 503
        return 'Internal Server Error'
      end
      url = "http://res.cloudinary.com#{link}"
      resp = Faraday.get(url).body
      return resp
    end

    get '/api/*' do
      params_string = params[:splat].first
      url = "https://#{API_DOMAIN}/api/#{params_string}"
      resp = Faraday.get(url).body
      return resp
    end

    def forward_webhook(token, target_domain, include_content_headers: false)
      puts "\n=== Incoming Webhook ==="
      puts "Token: #{token}"

      # Log raw request and payload
      raw_body = request.body.read
      puts "Raw body: #{raw_body}"
      request.body.rewind

      request_payload = JSON.parse(raw_body)
      puts "Parsed payload: #{request_payload.inspect}"
      request.body.rewind

      # Log headers being forwarded
      puts "\n=== Headers ==="
      forwarded_headers = request.env
                                 .select { |k, v| k.start_with?('HTTP_') }
                                 .transform_keys { |k| k.sub(/^HTTP_/, '').split('_').collect(&:capitalize).join('-') }

      forwarded_headers['Host'] = URI("https://#{target_domain}").host
      forwarded_headers['Content-Type'] = 'application/json'
      puts "Forwarding headers: #{forwarded_headers.inspect}"

      # Log target details
      target_url = "https://#{target_domain}/hook/#{URI.encode_www_form_component(token)}"
      puts "\n=== Forwarding ==="
      puts "Target URL: #{target_url}"
      puts "Sending body: #{raw_body}"

      # Make request
      conn = Faraday.new(url: target_url) do |f|
        f.headers.merge!(forwarded_headers)
        f.adapter Faraday.default_adapter
      end

      response = conn.post do |req|
        req.body = raw_body
      end

      # Log response
      puts "\n=== Response ==="
      puts "Status: #{response.status}"
      puts "Body: #{response.body}"

      [response.status, response.body]
    rescue => e
      puts "\n=== Error ==="
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
      raise e
    end
    
    # Main webhook route
    post '/hook/:token' do
      status, body = forward_webhook(params[:token], API_DOMAIN)
      status 200
      body
    rescue => e
      puts "\n=== Error ==="
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
      status 500
      { error: e.message }.to_json
    end

    # PDO webhook route
    post '/pdo/hook/:token' do
      status, body = forward_webhook(params[:token], PDO_DOMAIN)
      status 200
      body
    rescue => e
      puts "\n=== Error ==="
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
      status 500
      { error: e.message }.to_json
    end

    post '/api/create_dispute' do
      begin
        puts params.inspect
        if params.count == 0
          status 503
          return [{result: 'error', message: 'There are required parameters'}].to_json
        end
        url = "https://#{API_DOMAIN}/api/create_dispute"
        puts "check 0"
        puts url
        payload = {}
        params.each do |key, value|
          payload[key] = if value.is_a?(Hash) && value[:tempfile]
                           # This is a file upload. Include both the file and the original filename.
                           Faraday::UploadIO.new(value[:tempfile].path, value[:type], value[:filename])
                         else
                           # This is a regular parameter.
                           value
                         end
        end
        puts payload.inspect
        puts "check 1"
        conn = Faraday.new(url: url) do |c|
          c.request :multipart
          c.request :url_encoded
          c.adapter Faraday.default_adapter
        end
        puts "check 2"
        response = conn.post do |req|
          req.body = payload
        end
        return response.body
      rescue => ex
        puts ex.message
        puts ex.backtrace.join("\n\t")
      end
    end

    post ['/api/save_push', '/api/exception'] do
      puts params.inspect
      if params.count == 0
        status 503
        return [{result: 'error', message: 'There are required parameters'}].to_json
      end
      path = request.path_info.sub('/api/', '')
      url = "https://#{API_DOMAIN}/api/#{path}"
      conn = Faraday.new(url: url) do |c|
        c.request :url_encoded
        c.adapter Faraday.default_adapter
      end
      response = conn.post do |req|
        req.body = params  # Forward all POST data as-is
      end
      return response.body
    end

    # Separate route for callback with JSON handling
    post '/api/callback/*' do
      puts params.inspect
      if params.count == 0
        status 503
        return [{result: 'error', message: 'There are required parameters'}].to_json
      end

      path = request.path_info.sub('/api/', '')
      url = "https://#{API_DOMAIN}/api/#{path}"

      # Get raw body and headers
      request.body.rewind
      raw_body = request.body.read

      # Parse payload based on content type
      payload = if request.content_type == 'application/json'
                  JSON.parse(raw_body) rescue {}
                else
                  URI.decode_www_form(raw_body).to_h rescue {}
                end

      # Merge all data
      data = {
        params: params,
        body: payload,
        headers: request.env.select { |k,v| k.start_with?('HTTP_') },
        method: request.request_method,
        content_type: request.content_type,
        query_string: request.query_string,
        ip: request.ip,
        user_agent: request.user_agent
      }

      # Create Faraday connection with JSON handling
      conn = Faraday.new(url: url) do |c|
        c.request :json
        c.headers['Content-Type'] = 'application/json'
        c.adapter Faraday.default_adapter
      end

      # Forward request with all data
      response = conn.post do |req|
        req.body = data.to_json
      end

      return response.body
    end

  end
end