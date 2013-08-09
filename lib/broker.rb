require 'json'

class Broker
  attr_accessor :payload 

  STAGING_ROOT = '/var/www/vhosts/movielala.com/staging/'

  def branch
    payload['commits'][0]['branch']
  end

  def folder
    branch.to_s.gsub(/([\/-])/, '_')
  end

  def deploy_exists?
    File.exists? deploy_path
  end

  def allow_deploy?
    branch.include?('feature')
  end

  def deploy_path
    STAGING_ROOT + folder
  end

  def deploy
    if allow_deploy?
      if deploy_exists?
        Commands.fire(run: :update, in: deploy_path)
      else
        Commands.fire(run: :create, in: deploy_path, branch: branch)
      end
    end
  end

  def self.with_payload payload
    broker = new
    broker.payload = payload
    broker
  end

  def self.deploy payload
    broker = new
    broker.payload = payload
    broker.deploy
  end
end
