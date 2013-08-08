require 'rubygems'
require 'sinatra'
require_relative 'lib/broker'
require_relative 'lib/commands'

post '/' do
  Broker.deploy(request.body.read.to_s)
  ""
end
