require 'yaml'

class Settings
  def initialize
    file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'settings.yml'))
    @settings = YAML.load_file(file)
  end

  def chat_integration
    @settings['chat_integration']
  end

  def api_token
    @settings['api_token'][chat_integration]
  end
end
