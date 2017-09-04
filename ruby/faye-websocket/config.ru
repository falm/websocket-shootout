require 'bundler/setup'
require_relative 'server'
require 'stackprof'
require 'ruby-prof'

# Faye::WebSocket.load_adapter('puma')
Faye::WebSocket.load_adapter('thin')

#use StackProf::Middleware, enabled: true, mode: :object, interval: 1000, save_every: 5, raw: true
#use Rack::RubyProf
# result = RubyProf.profile do

  run Server.new
# end


# printer = RubyProf::MultiPrinter.new(result)
# printer.print(:path => "./tmp/profile", :profile => "profile")