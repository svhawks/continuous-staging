require 'flowdock'
class FlowDockIntegration < Integration
  API_TOKEN = '182efbfc0aceda25182c8d982a2e1dfd'

  def api_token
    API_TOKEN
  end

  def client
    @client ||= Flowdock::Flow.new(:api_token => api_token, :external_user_name => from)
  end

  def update
    client.push_to_chat(content: message)
  end
end

