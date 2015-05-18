require_relative '../../lib/slack_integration'
require_relative '../spec_helper'

describe SlackIntegration do
  let(:application) { Application.new(url: 'http://%{branch}.test.com') }
  context 'update' do
    subject { SlackIntegration.new(application) }

    before do
      stub_request(:post, "https://hooks.slack.com/services/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")
    end

    it 'posts to Slack with proper payload' do
      SlackIntegration.any_instance.stub(:path).and_return('/var/some-branch')
      SlackIntegration.any_instance.stub(:payload).and_return('foo')

      subject.update
      expect(WebMock).to have_requested(:post, "https://hooks.slack.com/services/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")
    end
  end
end

