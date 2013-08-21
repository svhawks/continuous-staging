class Cleaner
  attr_reader :deploys_to_remove

  STAGING_ROOT = '/var/www/vhosts/movielala.com/staging/'

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
      unless command.pull
        @deploys_to_remove << path
      end
    end

    command.rm_rf(deploys_to_remove)
  end
end