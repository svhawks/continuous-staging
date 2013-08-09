require 'rubygems'
require 'sinatra'
require_relative 'lib/broker'
require_relative 'lib/commands'

configure do
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

get '/' do
  'OK'
end

post '/' do
  begin
    payload = params[:payload]
    if payload
      logger.info payload
      Broker.deploy(JSON.parse(payload))
    end
  rescue Exception => e
    logger.info "===Something Went Wrong==="
    logger.info e
  end
  ""
end
