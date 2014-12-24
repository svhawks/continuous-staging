require_relative '../../lib/settings'
require_relative '../spec_helper'

describe Settings do
  let(:settings) { YAML.load(SETTINGS_YAML) }

  before do
    allow(YAML).to receive(:load_file).and_return(settings)
  end

  describe 'apps' do
    subject { Settings.apps.first }

    it 'loads applications' do
      expect(subject.name).to eql('Movielala')
    end
  end

  describe 'find' do
    subject { Settings.find('Movielala') }

    it 'finds app by name' do
      expect(subject).to be_a(Application)
    end
  end
end
