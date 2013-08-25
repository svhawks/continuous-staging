require 'hipchat-api'

class HipChatIntegration
  attr_accessor :path

  API_TOKEN = '45114da976749717e96a765410f5ab'

  def client
    @client ||= HipChat::API.new(api_token)
  end

  def api_token
    API_TOKEN
  end

  def room_id
    'web-dev'
  end

  def update
    client.room_message(room_id, from, message)
  end

  def from
    'MLLDeployBot'
  end

  def message
    "#{url} has been deployed!"
  end

  def self.update path
    integration = new
    integration.path = path
    integration.update
  end

  private
  def url
    sub_domain = path.split('/').last
    "http://#{sub_domain}.staging.movielala.com"
  end
end
