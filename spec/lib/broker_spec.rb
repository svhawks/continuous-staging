require_relative '../../lib/broker'
require_relative '../spec_helper'

describe Broker do
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
    its(:folder){ should == 'awesome_feature' }
    its(:deploy_exists?){ should be_false }
    its(:deploy_path){ should == '/var/www/vhosts/movielala.com/staging/awesome_feature' }
  end

  context "allow_deploy?" do
    it "ignores hotfixes" do
      broker = Broker.with_payload({'commits' => [{'branch' => 'hotfix/some-bugfix'}]})
      expect(broker.allow_deploy?).to be_false
    end

    it "allows features" do
      broker = Broker.with_payload({'commits' => [{'branch' => 'features/some-bugfix'}]})
      expect(broker.allow_deploy?).to be_true
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
        Commands.should_receive(:fire).with(run: :update, in: 'some_path')
      end
    end

    context "with new deploy" do
      before do
        Broker.any_instance.stub(:deploy_exists?).and_return(false)
      end

      it "creates repo in the branch folder" do
        Commands.should_receive(:fire).with(run: :create, in: 'some_path', branch: 'features/awesome-feature')
      end
    end
  end
end
