require 'hipchat-api'
class HipChatIntegration < Integration
  API_TOKEN = '45114da976749717e96a765410f5ab'

  def api_token
    API_TOKEN
  end

  def client
    @client ||= HipChat::API.new(api_token)
  end

  def room_id
    'web-dev'
  end

  def update
    client.rooms_message(room_id, from, message)
  end
end

