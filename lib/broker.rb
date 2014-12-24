require 'json'
require 'active_support/all'
require_relative 'log'
require_relative 'settings'
require_relative 'app_helper'

class Broker
  include Log
  include AppHelper
  attr_accessor :payload

  def branch
    payload['ref'].gsub('refs/heads/', '').to_s
  end

  def folder
    branch.to_s.split('/').last.to_s.parameterize.dasherize
  end

  def deploy_exists?
    File.exist? deploy_path
  end

  def allow_deploy?
    current_app_exists? && branch && (branch.include?('feature') || %w(staging master production).include?(branch))
  end

  def deploy_path
    File.join(staging_root, folder)
  end

  def shared_path
    File.join(staging_root, 'shared')
  end

  def staging_root
    current_app.path
  end

  def name
    payload['repository']['name']
  end

  def deploy
    if allow_deploy?
      if deploy_exists?
        logger.info 'Existing deploy: now updating codebase'
        Commands.fire(run: :update, in: deploy_path, shared_path: shared_path)
      else
        logger.info 'New deploy: now setting up new app'
        Commands.fire(run: :create, in: deploy_path, branch: branch, shared_path: shared_path)
      end
    else
      logger.info "Branch #{branch} rejected"
    end
  end

  def self.with_payload(payload)
    broker = new
    broker.payload = payload
    broker
  end

  def self.deploy(payload)
    broker = new
    broker.payload = payload
    broker.deploy
  end
end
