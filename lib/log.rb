module Log
  def logger
    file = File.new(File.expand_path(File.join(File.dirname(__FILE__), '..', 'log', 'development.log')), 'a+')
    Logger.new file
  end
end
