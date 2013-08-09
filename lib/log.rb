require 'logger'
module Log
  def logger
    Logger.new STDOUT
  end
end
