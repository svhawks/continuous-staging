require 'open4'
require 'bundler'
require_relative 'log'
require_relative 'integration'
require_relative 'slack_integration'
require_relative 'settings'

class Commands
  include Log
  attr_accessor :pwd, :branch, :shared_path, :app

  def create
    ensure_working_directory
    clone
    update_submodule
    bundle
    link_db_config
    link_shared_log
    broadcast_new_deploy_on_chat
  end

  def update
    ensure_working_directory
    pull
    update_submodule
    bundle
    link_db_config
    link_shared_log
    touch_restart
    broadcast_update_on_chat
  end

  def ensure_working_directory
    FileUtils.mkdir_p pwd
  end

  def link_db_config
    run %(ln -nfs #{shared_db_config} #{target_db_config})
    run %(ln -nfs #{shared_mongodb_config} #{target_mongodb_config})
  end

  def link_shared_log
    run %(ln -nfs #{shared_log} #{target_log})
  end

  def pull
    run %(git reset HEAD && git checkout . && git clean -f -d && git pull origin #{branch})
  end

  def bundle
    run_with_clean_env %(bundle --path #{shared_bundle_path} --gemfile #{pwd}/Gemfile --without test development)
  end

  def broadcast_new_deploy_on_chat
    integration_class.update(app, pwd, :new_deploy)
  end

  def broadcast_update_on_chat
    integration_class.update(app, pwd, :update)
  end

  def self.fire(options)
    fork do
      command = new
      command.pwd = options[:in]
      command.branch = options[:branch]
      command.app = options[:app]
      command.shared_path = options[:shared_path]
      command.send(options[:run])
      exit!
    end
  end

  def clone
    run %(git clone #{repository_url} --branch #{branch} --single-branch #{pwd})
  end

  def update_submodule
    run %(git submodule init && git submodule update)
  end

  def repository_url
    app.git
  end

  def rm_rf(folders)
    if folders && folders.length > 0
      removal_command = "rm -rf #{folders.join(' ')}"
      run(removal_command, staging_root)
    end
  end

  def touch_restart
    run %(touch tmp/restart.txt && curl #{url} > /dev/null)
  end

  private

  def integration_class
    Module.const_get(app.chat_integration)
  end

  def shared_db_config
    File.join(shared_root, 'config/database.yml')
  end

  def shared_mongodb_config
    File.join(shared_root, 'config/mongoid.yml')
  end

  def shared_resque_config
    File.join(shared_root, 'config/settings/resque.yml')
  end

  def shared_session_store
    File.join(shared_root, 'config/initializers/session_store.rb')
  end

  def shared_bundle_path
    File.join(shared_root, 'bundle')
  end

  def staging_root
    '/var/www/vhosts/movielala.com/staging/'
  end

  def target_db_config
    "#{pwd}/config/database.yml"
  end

  def target_mongodb_config
    "#{pwd}/config/mongoid.yml"
  end

  def shared_log
    File.join(shared_root, 'log')
  end

  def target_log
    "#{pwd}/log"
  end

  def shared_root
    shared_path
  end

  def run(command, target = pwd)
    logger.info "Running #{command} in #{target}"
    error, success = nil
    status = Open4.popen4(command, chdir: target) do |_pid, _stdin, stdout, stderr|
      success = stdout.read.strip
      error = stderr.read.strip
      logger.info success
      logger.info error
    end

    logger.info "Status: #{status}"
    logger.info "STDOUT #{success}"
    logger.info "STDERR #{error}"

    [status.exitstatus, error, success]
  end

  def run_with_clean_env(command)
    Bundler.with_clean_env do
      run command
    end
  end

  def url
    sub_domain = pwd.split('/').last
    "http://#{sub_domain}.staging.movielala.com"
  end
end
