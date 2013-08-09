require 'rubygems'
require 'sinatra'
require_relative 'lib/broker'
require_relative 'lib/commands'

configure do
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

post '/' do
  begin
    request_body = request.body.read.to_s
    logger.info "===Request Received==="
    logger.info request_body
    logger.info "===Request END==="
    Broker.deploy(request_body)
  rescue Exception => e
    logger.info "===Something Went Wrong==="
    logger.info e
  end
  ""
end
