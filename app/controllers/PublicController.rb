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

    post '/hook/:token' do
      request_payload = JSON.parse(request.body.read)
      forwarded_headers = request.env.select { |k, v| k.start_with?('HTTP_') }
                                 .transform_keys { |k| k.sub(/^HTTP_/, '').split('_').collect(&:capitalize).join('-') }
      conn = Faraday.new(url: "https://#{API_DOMAIN}/hook/#{params[:token]}") do |faraday|
        faraday.headers.merge!(forwarded_headers)  # Merge the extracted headers
        faraday.adapter Faraday.default_adapter
      end
      response = conn.post do |req|
        req.body = request_payload.to_json
      end
      status 200
      response.body
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