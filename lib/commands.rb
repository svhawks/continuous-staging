require 'open4'
require_relative 'log'

class Commands
  include Log
  attr_accessor :pwd, :branch

  def create
    ensure_working_directory
    clone
    update_submodule
    bundle
    link_db_config
    ensure_proper_permissions
  end

  def update
    ensure_working_directory
    pull
    update_submodule
    bundle
    link_db_config
    ensure_proper_permissions
    touch_restart
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

  def pull
    run %{git checkout . && git pull origin #{branch}}
  end

  def bundle
    run_with_clean_env %{bundle --path #{shared_bundle_path} --gemfile #{pwd}/Gemfile --without test development}
  end

  def self.fire(options)
    command = new
    command.pwd = options[:in]
    command.branch = options[:branch] if options[:branch]
    command.send(options[:run])
    command
  end

  def clone
    run %{git clone git@bitbucket.org:movielalainc/web.git --branch #{branch} --single-branch #{pwd}}
  end

  def update_submodule
    run %{git submodule init && git submodule update}
  end

  def rm_rf folders
    removal_command = "rm -rf #{folders.join(' ')}"
    run(removal_command, staging_root)
  end

  private

  def shared_db_config
    shared_root + 'config/database.yml'
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

  def touch_restart
    run %{touch tmp/restart.txt}
  end

  def run(command, target = pwd)
    logger.info "Running #{command} in #{target}"
    Open4::popen4(command, chdir: target) do |pid, stdin, stdout, stderr|
      logger.info stdout.read.strip
      logger.info stderr.read.strip
    end
  end

  def run_with_clean_env command
    Bundler.with_clean_env do
      run command
    end
  end
end
