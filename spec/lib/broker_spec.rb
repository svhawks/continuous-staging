require_relative '../../lib/broker'
require_relative '../spec_helper'

class Commands; end

describe Broker do
  let(:settings) { YAML.load(SETTINGS_YAML) }

  before do
    Settings.any_instance.stub(:configuration)
      .and_return(settings)
  end

  context "Broker with payload" do
    it "instantiates a broker and assigns the payload" do
      broker = Broker.with_payload({})
      expect(broker).to be_a(Broker)
      expect(broker.payload).to eql({})
    end
  end

  context "methods" do
    subject{ Broker.with_payload(payload)}
    its(:branch){ should == 'features/awesome-feature' }
    its(:folder){ should == 'awesome-feature' }
    its(:deploy_exists?){ should be false }
    its(:name){ should == 'github' }
    its(:staging_root){ should == '/home/deployer/github' }
    its(:deploy_path){ should == '/home/deployer/github/awesome-feature' }

    it 'gets current app' do
      expect(subject.current_app.name).to eql('github')
    end
  end

  context "subdomain string manipulation" do
    subject{ Broker.with_payload(payload)}

    it "handles weird chars" do
      Broker.any_instance.stub(:branch).and_return('Şahin')
      expect(subject.folder).to eql('sahin')
    end

    it "handles underscores" do
      Broker.any_instance.stub(:branch).and_return('some_underscored_name')
      expect(subject.folder).to eql('some-underscored-name')
    end
  end

  context "allow_deploy?" do
    let(:broker){ Broker.with_payload(payload) } 

    it 'ignores non existing apps' do
      broker.stub(:current_app).and_return(nil)
      expect(broker.allow_deploy?).to be false
    end

    it "ignores hotfixes" do
      broker.stub(:branch).and_return('hotfixes/fix-something')
      expect(broker.allow_deploy?).to be false
    end

    ['features/some-feature', 'master', 'production'].each do |branch|
      it "allows #{branch}" do
        broker.stub(:branch).and_return(branch)
        expect(broker.allow_deploy?).to be true
      end
    end
  end

  context "deploy" do
    let(:broker){ Broker.with_payload(payload) } 

    before do
      Broker.any_instance.stub(:deploy_path).and_return('some_path')
    end

    after do
      broker.deploy
    end

    context "when deploy is allowed" do
      it "runs deploy" do
        Broker.any_instance.stub(:allow_deploy?).and_return(true)
        Commands.should_receive(:fire).once()
      end
    end

    context "when deploy is not allowed" do
      it "does not run deploy" do
        Broker.any_instance.stub(:allow_deploy?).and_return(false)
        Commands.should_receive(:fire).never()
      end
    end

    context "with existing deploy" do
      it "updates the codebase" do
        Broker.any_instance.stub(:deploy_exists?).and_return(true)
        Commands.should_receive(:fire).with(run: :update, in: 'some_path', shared_path: '/home/deployer/github/shared')
      end
    end

    context "with new deploy" do
      before do
        Broker.any_instance.stub(:deploy_exists?).and_return(false)
      end

      it "creates repo in the branch folder" do
        Commands.should_receive(:fire).with(run: :create, in: 'some_path', branch: 'features/awesome-feature', shared_path: '/home/deployer/github/shared')
      end
    end
  end
end
