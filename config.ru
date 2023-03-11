require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require_rel './config/config'
require_rel './app/lib'
require_rel './app/controllers/ApplicationController'
require_rel './app/controllers'

`rake version:bump:revision`

begin
  use TSX::PublicController
  run TSX::ApplicationController
rescue => e
  puts "EXCEPTION FROM CONFIG.RU ----------------"
  puts e.message
  puts e.backtrace.join("\t\n")
end