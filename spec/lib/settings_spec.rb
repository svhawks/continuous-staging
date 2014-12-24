require_relative '../../lib/settings'
require_relative '../spec_helper'

describe Settings do
  let(:settings) { YAML.load(SETTINGS_YAML) }

  before do
    Settings.any_instance.stub(:configuration)
      .and_return(settings)
  end

  describe 'apps' do
    subject { Settings.apps.first }

    it 'loads applications' do
      expect(subject.name).to eql('github')
    end
  end

  describe 'find' do
    subject { Settings.find('github') }

    it 'finds app by name' do
      expect(subject).to be_a(Application)
    end
  end
end
