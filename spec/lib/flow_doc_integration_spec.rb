require_relative '../../lib/integration'
require_relative '../../lib/flow_dock_integration'
require_relative '../spec_helper'

describe FlowDockIntegration do
  context "client" do
    subject { FlowDockIntegration.new.client }

    it "should be a flow dock api client" do
      expect(subject).to be_a(Flowdock::Flow)
    end

    it "inits the client with proper token" do
      FlowDockIntegration.any_instance.stub(:api_token).and_return('some-token')
      expect(subject.api_token).to eql('some-token')
    end
  end

  context "update" do
    subject { FlowDockIntegration.new }

    it "delegates to room broadcast msg" do
      Integration.any_instance.stub(:message_for_new_deploy).and_return('something hppnd')
      Flowdock::Flow.any_instance.should_receive(:push_to_chat).with(content: 'something hppnd')
      subject.update
    end
  end
end

