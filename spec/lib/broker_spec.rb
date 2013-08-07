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
    its(:branch){ should == 'awesome-feature' }
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
        Commands.should_receive(:fire).with(run: :create, in: 'some_path')
        broker.deploy
      end
    end
  end
end

def payload
<<EOF
{
    "canon_url": "https://bitbucket.org", 
    "commits": [
        {
            "author": "marcus", 
            "branch": "features/awesome-feature", 
            "files": [
                {
                    "file": "somefile.py", 
                    "type": "modified"
                }
            ], 
            "message": "Added some more things to somefile.py", 
            "node": "620ade18607a", 
            "parents": [
                "702c70160afc"
            ], 
            "raw_author": "Marcus Bertrand <marcus@somedomain.com>", 
            "raw_node": "620ade18607ac42d872b568bb92acaa9a28620e9", 
            "revision": null, 
            "size": -1, 
            "timestamp": "2012-05-30 05:58:56", 
            "utctimestamp": "2012-05-30 03:58:56+00:00"
        }
    ], 
    "repository": {
        "absolute_url": "/marcus/project-x/", 
        "fork": false, 
        "is_private": true, 
        "name": "Project X", 
        "owner": "marcus", 
        "scm": "git", 
        "slug": "project-x", 
        "website": "https://atlassian.com/"
    }, 
    "user": "marcus"
}
EOF
end
