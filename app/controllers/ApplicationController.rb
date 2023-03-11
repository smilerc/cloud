require 'active_support'
require 'active_support/all'
require 'active_support/core_ext'
require 'action_view/helpers'
require 'action_view/helpers/number_helper'
require 'action_view/helpers/date_helper'
require 'sinatra/multi_route'
require 'colorize'
require 'sinatra/reloader'
require 'faraday_middleware'
require 'faraday'
require 'active_support'
require 'action_view'
require 'telegram/bot'
require 'telegram/bot/exceptions'
require 'sinatra/flash'


module TSX

  class ApplicationController < Sinatra::Base

    if ENV['production'] == 'yes'
      set :show_exceptions, false
    else
      set :show_exceptions, true
    end

    use Rack::Session::Cookie, secret: 'sbdddjfksdjfttsxtsxpostsetsession789999333hhjgg'

    register Sinatra::Reloader if not production?

    register Sinatra::Partial
    register Sinatra::Flash
    register Sinatra::DateForms
    register Sinatra::MultiRoute
    register Sinatra::ConfigFile
    register WillPaginate::Sinatra

    helpers Sinatra::HtmlHelpers
    helpers Sinatra::CountryHelpers
    helpers ActionView::Helpers::DateHelper
    helpers ActionView::Helpers::SanitizeHelper

    include ActionView::Helpers::DateHelper
    include TSX::Helpers
    include Colorize

    set views: "#{ROOT}/app/views"
    set public_folder: "#{ROOT}/public"
    @p = 1
    
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
