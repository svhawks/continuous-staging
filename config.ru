require 'rubygems'
require 'sinatra'
require File.expand_path '../app.rb', __FILE__

log = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
$stdout.reopen(log)
$stderr.reopen(log)

$stdout.sync = true
$stderr.sync = true

run Sinatra::Application
