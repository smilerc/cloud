module TSX
  class PublicController < TSX::ApplicationController

    get '/' do
      status 503
      'Internal Server Error'
    end

    get '/uid/:uid' do
      headers \
"Content-Type" => "text/plain; charset=utf-8"
      link = TSX::Encode.from_enc(params[:uid])
      url = "http://res.cloudinary.com#{link}"
      resp = Faraday.get(url).body
      return resp
    end

    get '/api/*' do
      params_string = params[:splat].first
      url = "https://nashobmen.dokku.superadminka.cc/api/#{params_string}"
      resp = Faraday.get(url).body
      return resp
    end


  end
end