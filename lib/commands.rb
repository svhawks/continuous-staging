require_relative 'log'

class Commands
  include Log
  attr_accessor :pwd, :branch

  def create
    cd_into_target
    clone
    update_submodule
    bundle
    link_db_config
  end

  def update
    cd_into_target
    pull
    update_submodule
    bundle
    touch_restart
  end

  def cd_into_target
    run %{mkdir -p #{pwd}}
    run %{cd #{pwd}}
  end

  def link_db_config
    run %{ln -nfs #{shared_db_config} #{target_db_config}}
  end

  def pull
    run %{git pull origin #{branch}}
  end

  def bundle
    run %{bundle --deployment --without test development}
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

  private

  def shared_db_config
    '/var/www/vhosts/movielala.com/staging/shared/config/database.yml'
  end

  def target_db_config
    "#{pwd}/config/database.yml"
  end

  def touch_restart
    run %{touch tmp/restart.txt}
  end

  def run command
    logger.info "Running #{command}"
    system command
  end
end
