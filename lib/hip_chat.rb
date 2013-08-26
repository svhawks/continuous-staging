require 'hipchat-api'

class HipChatIntegration
  attr_accessor :path, :type

  API_TOKEN = '45114da976749717e96a765410f5ab'

  def initialize
    @type = :new_deploy
  end

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
    message = send("message_for_#{type}")
    client.rooms_message(room_id, from, message)
  end

  def from
    'MLLDeployBot'
  end

  def message_for_new_deploy
    %{<a href="#{url}">#{url}</a> has been deployed!}
  end

  def message_for_update
    %{<a href="#{url}">#{url}</a> has been updated!}
  end

  def self.update(path, type = :new_deploy)
    integration = new
    integration.path = path
    integration.type = type
    integration.update
  end

  private
  def url
    sub_domain = path.split('/').last
    "http://#{sub_domain}.staging.movielala.com"
  end
end
