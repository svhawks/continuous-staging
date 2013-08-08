require_relative '../../lib/broker'
require_relative '../spec_helper'

describe Broker do
  context "Broker with payload" do
    it "instantiates a broker and assigns the payload" do
      broker = Broker.with_payload("payload")
      expect(broker).to be_a(Broker)
      expect(broker.payload).to eql("payload")
    end
  end

  context "branch" do
    subject{ Broker.with_payload(payload)}
    its(:branch){ should == 'features/awesome-feature' }
    its(:folder){ should == 'awesome_feature' }
    its(:deploy_exists?){ should be_false }
    its(:deploy_path){ should == '/var/www/vhosts/movielala/staging/awesome_feature' }
  end

  context "deploy" do
    let(:broker){ Broker.with_payload(payload) } 

    before do
      Broker.any_instance.stub(:deploy_path).and_return('some_path')
    end

    context "with existing deploy" do
      it "updates the codebase" do
        Broker.any_instance.stub(:deploy_exists?).and_return(true)
        Commands.should_receive(:fire).with(run: :update, in: 'some_path')
        broker.deploy
      end
    end

    context "with new deploy" do
      before do
        Broker.any_instance.stub(:deploy_exists?).and_return(false)
      end

      it "creates repo in the branch folder" do
        Commands.should_receive(:fire).with(run: :create, in: 'some_path', branch: 'features/awesome-feature')
        broker.deploy
      end
    end
  end
end
