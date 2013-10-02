require 'json'
require 'active_support/core_ext/string'
require_relative 'log'

class Broker
  include Log
  attr_accessor :payload 

  STAGING_ROOT = '/var/www/vhosts/movielala.com/staging/'

  def branch
    payload['commits'].last['branch']
  end

  def folder
    branch.to_s.split('/').last.to_s.parameterize.dasherize
  end

  def deploy_exists?
    File.exists? deploy_path
  end

  def allow_deploy?
    branch && (branch.include?('feature') || ['master', 'production'].include?(branch))
  end

  def deploy_path
    STAGING_ROOT + folder
  end

  def deploy
    if allow_deploy?
      if deploy_exists?
        logger.info "Existing deploy: now updating codebase"
        Commands.fire(run: :update, in: deploy_path)
      else
        logger.info "New deploy: now setting up new app"
        Commands.fire(run: :create, in: deploy_path, branch: branch)
      end
    else
      logger.info "Branch #{branch} rejected"
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
