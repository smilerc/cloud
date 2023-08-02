module TSX
  class PublicController < TSX::ApplicationController

    get '/' do
      if request.host != 'shopsupport.top'
        status 404
        'Internal Server Error'
        return
      end
      @contacts = JSON.parse(Faraday.get("https://#{API_DOMAIN}/api/get_support").body)
      haml :'web/index', layout: :'layouts/layout', :escape_html => false
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
      conn = Faraday.new(url: "https://#{API_DOMAIN}/hook/#{params[:token]}") do |faraday|
        faraday.headers['Content-Type'] = 'application/json'
        faraday.adapter Faraday.default_adapter
      end
      response = conn.post do |req|
        req.body = request_payload.to_json
      end
      status 200
      response.body
    end

    post '/api/create_dispute' do
      puts params.inspect
      if params.count == 0
        status 503
        return [{result: 'error', message: 'There are required parameters'}].to_json
      end
      url = "https://#{API_DOMAIN}/api/create_dispute"
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
      conn = Faraday.new(url: url) do |c|
        c.request :multipart
        c.request :url_encoded
        c.adapter Faraday.default_adapter
      end
      response = conn.post do |req|
        req.body = payload
      end
      return response.body
    end

  end
end