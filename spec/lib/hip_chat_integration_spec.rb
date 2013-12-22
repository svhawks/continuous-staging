require_relative '../../lib/integration'
require_relative '../../lib/hip_chat_integration'
require_relative '../spec_helper'

describe HipChatIntegration do
  context "client" do
    subject { HipChatIntegration.new.client }

    it "should be a hipchat api client" do
      expect(subject).to be_a(HipChat::API)
    end

    it "inits the client with proper token" do
      HipChatIntegration.any_instance.stub(:api_token).and_return('some-token')
      expect(subject.token).to eql('some-token')
    end
  end

  context "update" do
    subject { HipChatIntegration.new }

    it "delegates to room broadcast msg" do
      Integration.any_instance.stub(:message_for_new_deploy).and_return('something hppnd')
      HipChatIntegration.any_instance.stub(:room_id).and_return('test-room')
      HipChat::API.any_instance.should_receive(:rooms_message).with('test-room', 'MLLDeployBot', 'something hppnd')
      subject.update
    end
  end
end
