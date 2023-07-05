module TSX
  class PublicController < TSX::ApplicationController

    get '/' do
      status 503
      'Internal Server Error'
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
      url = "https://nashobmen.dokku.goodapi.top/api/#{params_string}"
      resp = Faraday.get(url).body
      return resp
    end

    post '/api/create_dispute' do
      puts params.inspect
      if params[:splat].count == 0
        status 503
        return [{result: 'error', 'There are required parameters'}].to_json
      end
      params_string = params[:splat].first
      url = "https://nashobmen.dokku.goodapi.top/api/#{params_string}"
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