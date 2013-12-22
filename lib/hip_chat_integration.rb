require 'hipchat-api'
class HipChatIntegration < Integration
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

