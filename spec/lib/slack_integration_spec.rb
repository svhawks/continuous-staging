require_relative '../../lib/integration'
require_relative '../../lib/slack_integration'
require_relative '../spec_helper'

describe SlackIntegration do
  context "client" do
    subject { SlackIntegration.new.client }

    it "should be a hipchat api client" do
      expect(subject).to eql(Slack)
    end
  end

  context "update" do
    subject { SlackIntegration.new }

    it "delegates to room broadcast msg" do
      Integration.any_instance.stub(:message_for_new_deploy).and_return('something hppnd')
      SlackIntegration.any_instance.stub(:channel).and_return('test-room')
      Slack.should_receive(:chat_postMessage)#.with('test-room', 'MLLDeployBot', 'something hppnd')
      subject.update
    end
  end
end
