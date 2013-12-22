require_relative '../../lib/settings'
require_relative '../spec_helper'

describe Settings do
  it 'reads from config file' do
    file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'settings.yml'))
    YAML.should_receive(:load_file).with(file)
    Settings.new
  end

  context 'chat_integration' do
    it 'returns chat_integration from settings' do
      YAML.stub(:load_file).and_return('chat_integration' => 'foo')
      expect(Settings.new.chat_integration).to eql('foo')
    end
  end

  context 'integration_api_token' do
    subject { Settings.new }

    before do
      YAML.stub(:load_file).and_return('api_token' => { 'foo' => '123' })
      subject.stub(:chat_integration).and_return('foo')
    end

    it 'returns the api token' do
      expect(subject.api_token).to eql('123')
    end
  end
end
