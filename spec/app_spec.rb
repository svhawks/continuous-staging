require_relative 'spec_helper'
require_relative '../app'

describe 'App' do
  context 'POST /' do
    it 'delegates to broker' do
      Broker.should_receive(:deploy)
      post '/', 'payload={}', 'CONTENT_TYPE' => 'application/x-www-form-urlencoded'
      expect(last_response.status).to eql(200)
    end
  end
end
