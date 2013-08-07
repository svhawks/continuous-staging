require 'json'
require 'commands'

class Broker
  attr_accessor :payload 

  STAGING_ROOT = '/var/www/vhosts/movielala/staging/'

  def branch
    parsed_payload['commits'][0]['branch'].to_s.gsub('features/','')
  end
  
  def deploy_exists?
    File.exists? deploy_path
  end

  def deploy_path
    STAGING_ROOT + branch.gsub('-', '_')
  end

  def deploy
    if deploy_exists?
      Commands.fire(run: :update, in: deploy_path)
    else
      Commands.fire(run: :create, in: deploy_path)
    end
  end

  def self.with_payload payload
    broker = new
    broker.payload = payload
    broker
  end

  private
  def parsed_payload
    @parsed_payload ||= JSON.parse payload
  end
end
