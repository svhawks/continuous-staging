require 'flowdock'
class FlowDockIntegration < Integration
  def client
    @client ||= Flowdock::Flow.new(:api_token => api_token, :external_user_name => from)
  end

  def update
    client.push_to_chat(content: message)
  end
end

