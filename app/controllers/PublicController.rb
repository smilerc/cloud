module TSX
  class PublicController < TSX::ApplicationController

    get '/' do
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


  end
end