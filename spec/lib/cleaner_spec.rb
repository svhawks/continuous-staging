require_relative '../../lib/cleaner'
require_relative '../spec_helper'

describe Cleaner do
  before do
    Commands.any_instance.stub(:run)
  end

  context 'deploys' do
    subject { Cleaner.new.deploys }

    let(:app1) { Application.new(path: '/app1') }
    let(:app2) { Application.new(path: '/app2') }

    before do
      Settings.stub(:apps).and_return([app1, app2])
      Dir.stub(:[]).with('/app1/*').and_return(['/app1/master', '/app1/staging', '/app1/shared'])
      Dir.stub(:[]).with('/app2/*').and_return(['/app2/master', '/app2/staging', '/app2/shared'])
    end

    it 'has a list of all deploys' do
      expect(subject).to be_an(Array)
      expect(subject).to include('/app1/master')
      expect(subject).to include('/app2/master')
    end

    it 'does not include shared' do
      expect(subject).to_not include('/app1/shared')
      expect(subject).to_not include('/app2/shared')
    end

    it 'does not include runner' do
      expect(subject).to_not include('/some/place/runner')
    end
  end

  context 'run' do
    subject { Cleaner.new }

    before do
          Commands.any_instance.stub(:link_db_config)
      Cleaner.any_instance.stub(:deploys).and_return(['/some/path'])
    end

    it 'updates code for all deploys' do
      Commands.any_instance.should_receive(:pwd=).with('/some/path')
      Commands.any_instance.stub(:pwd).and_return('/some/path')
      Commands.any_instance.should_receive(:pull)
      subject.run
    end

    context 'with update failure' do
      it 'marks deploy for deletion' do
        Commands.any_instance.stub(:pull).and_return([1, "Couldn't find remote ref non-existent-branch"])
        subject.run
        expect(subject.deploys_to_remove).to eql(['/some/path'])
      end
    end

    context 'with update success' do
      before do
        Commands.any_instance.stub(:pull).and_return([0, nil, nil])
      end

      context 'restarting the app' do
        before do
          Commands.any_instance.stub(:link_db_config)
        end

        context 'with new codes' do
          it 'restarts the app' do
            Commands.any_instance.stub(:pull).and_return([0, nil, nil])
            Commands.any_instance.should_receive(:touch_restart)
            subject.run
          end
        end

        context 'with no new updates' do
          it 'does not restart the app' do
            Commands.any_instance.stub(:pull).and_return([0, nil, 'Already up-to-date.'])
            Commands.any_instance.should_receive(:touch_restart).never
            subject.run
          end
        end
      end

      it 're links the shared db' do
        Commands.any_instance.should_receive(:link_db_config)
        subject.run
      end
    end

    it 'runs command to delete deploys' do
      Commands.any_instance.stub(:link_db_config)
      Cleaner.any_instance.stub(:deploys_to_remove).and_return(['/some/path', '/some/other/path'])
      Commands.any_instance.should_receive(:rm_rf).with(['/some/path', '/some/other/path'])
      subject.run
    end
  end
end
