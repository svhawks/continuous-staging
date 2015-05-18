require_relative '../lib/commands'
class Cleaner
  attr_reader :deploys_to_remove

  def initialize
    @deploys_to_remove = []
  end

  def deploys
    Settings.apps.map do |app|
      Dir["#{app.path}/*"].reject do |dir|
        dir =~ /shared/
      end
    end.flatten
  end

  def command
    @command ||= Commands.new
  end

  def run
    deploys.each do |path|
      command.pwd = path
      command.shared_path = path
      status, error, success = command.pull
      if status == 1 && error.to_s.include?("Couldn't find remote ref")
        @deploys_to_remove << path
      else
        command.link_db_config
        unless success.to_s.include?('Already up-to-date.')
          command.touch_restart
        end
      end
    end

    command.rm_rf(deploys_to_remove)
  end
end
