class Commands
  attr_accessor :pwd, :branch

  def create
    cd_into_target
    clone
    update_submodule
    link_db_config
  end

  def update
    cd_into_target
    pull
    update_submodule
    touch_restart
  end

  def cd_into_target
    system %{mkdir -p #{pwd}}
    system %{cd #{pwd}}
  end

  def link_db_config
    system %{ln -nfs #{shared_db_config} #{target_db_config}}
  end

  def pull
    system %{git pull origin #{branch}}
  end

  def self.fire(options)
    command = new
    command.pwd = options[:in]
    command.branch = options[:branch] if options[:branch]
    command.send(options[:run])
    command
  end

  def clone
    system %{git clone git@bitbucket.org:movielalainc/web.git --branch #{branch} --single-branch #{pwd}}
  end

  def update_submodule
    system %{git submodule init && git submodule update}
  end

  private

  def shared_db_config
    '/var/www/vhosts/movielala/staging/shared/config/database.yml'
  end

  def target_db_config
    "#{pwd}/config/database.yml"
  end

  def touch_restart
    system %{touch tmp/restart.txt}
  end
end

