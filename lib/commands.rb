require 'open4'
require_relative 'log'
require_relative 'integration'
require_relative 'hip_chat_integration'
require_relative 'flow_dock_integration'
require_relative 'settings'

class Commands
  include Log
  attr_accessor :pwd, :branch

  def create
    ensure_working_directory
    clone
    update_submodule
    bundle
    link_db_config
    link_shared_log
    ensure_proper_permissions
    broadcast_new_deploy_on_chat
  end

  def update
    ensure_working_directory
    pull
    update_submodule
    bundle
    link_db_config
    link_shared_log
    ensure_proper_permissions
    touch_restart
    broadcast_update_on_chat
  end

  def ensure_working_directory
    FileUtils.mkdir_p pwd
  end

  def ensure_proper_permissions
    run %{chown -R www-data:www-data #{pwd}}
  end

  def link_db_config
    run %{ln -nfs #{shared_db_config} #{target_db_config}}
  end

  def link_shared_log
    run %{ln -nfs #{shared_log} #{target_log}}
  end

  def pull
    run %{git reset HEAD && git checkout . && git clean -f -d && git pull origin #{branch}}
  end

  def bundle
    run_with_clean_env %{bundle --path #{shared_bundle_path} --gemfile #{pwd}/Gemfile --without test development}
  end

  def broadcast_new_deploy_on_chat
    integration_class.update(pwd, :new_deploy)
  end

  def broadcast_update_on_chat
    integration_class.update(pwd, :update)
  end

  def self.fire(options)
    command = new
    command.pwd = options[:in]
    command.branch = options[:branch] if options[:branch]
    command.send(options[:run])
    command
  end

  def clone
    run %{git clone git@github.com:movielala/web.git --branch #{branch} --single-branch #{pwd}}
  end

  def update_submodule
    run %{git submodule init && git submodule update}
  end

  def rm_rf folders
    if folders && folders.length > 0
      removal_command = "rm -rf #{folders.join(' ')}"
      run(removal_command, staging_root)
    end
  end

  def touch_restart
    run %{touch tmp/restart.txt && curl #{url} > /dev/null}
  end

  private

  def integration
    @integration ||= Settings.new.chat_integration
  end

  def integration_class
    Module.const_get(integration)
  end

  def shared_db_config
    shared_root + 'config/database.yml'
  end

  def shared_resque_config
    shared_root + 'config/settings/resque.yml'
  end

  def shared_session_store
    shared_root + 'config/initializers/session_store.rb'
  end

  def shared_bundle_path
    shared_root + 'bundle'
  end

  def staging_root
    '/var/www/vhosts/movielala.com/staging/'
  end

  def shared_root
    '/var/www/vhosts/movielala.com/staging/shared/'
  end

  def target_db_config
    "#{pwd}/config/database.yml"
  end

  def shared_log
    shared_root + 'log'
  end

  def target_log
    "#{pwd}/log"
  end

  def run(command, target = pwd)
    logger.info "Running #{command} in #{target}"
    error, success = nil
    status = Open4::popen4(command, chdir: target) do |pid, stdin, stdout, stderr|
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

  def run_with_clean_env command
    Bundler.with_clean_env do
      run command
    end
  end

  def url
    sub_domain = pwd.split('/').last
    "http://#{sub_domain}.staging.movielala.com"
  end


end
