require 'sinatra/reloader'
require 'faraday_middleware'
require 'faraday'


module TSX

  class ApplicationController < Sinatra::Base

    if ENV['production'] == 'yes'
      set :show_exceptions, false
    else
      set :show_exceptions, true
    end

    use Rack::Session::Cookie, secret: 'sbdddjfksdjfttsxtsxpostsetsession789999333hhjgg'

    set views: "#{ROOT}/app/views"
    set public_folder: "#{ROOT}/public"
    @p = 1

    # Cloudinary.config do |config|
    #   config.cloud_name = CLOUDINARY_CLOUD_NAME
    #   config.api_key = CLOUDINARY_API_KEY
    #   config.api_secret = CLOUDINARY_SECRET
    #   config.cdn_subdomain = true
    # end
    #
    before do
      cache_control :no_cache
      headers \
"Pragma"   => "no-cache",
"Expires" => "0"
    end

    not_found do
      status 404
      'Internal Server Error'
    end

  end
end
