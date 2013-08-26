class Cleaner
  attr_reader :deploys_to_remove

  STAGING_ROOT = '/var/www/vhosts/movielala.com/staging'

  def initialize
    @deploys_to_remove = []
  end

  def deploys
    Dir["#{STAGING_ROOT}/*"].reject do |dir|
      dir =~ /runner|shared/
    end
  end

  def command
    @command ||= Commands.new
  end

  def run
    deploys.each do |path|
      command.pwd = path
      status, error, success = command.pull
      if status == 1 && error.to_s.include?("Couldn't find remote ref")
        @deploys_to_remove << path
      else
        command.ensure_proper_permissions
        command.link_db_config
        unless success.to_s.include?('Already up-to-date.')
          command.touch_restart
        end
      end
    end

    command.rm_rf(deploys_to_remove)
  end
end
