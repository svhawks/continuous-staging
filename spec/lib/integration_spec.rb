require_relative '../../lib/integration'
require_relative '../spec_helper'

describe Integration do

  context "messages" do
    subject { Integration.new }

    it "has proper new deploy message" do
      Integration.any_instance.stub(:path).and_return('/var/some-branch')
      expect(subject.message_for_new_deploy).to eql('<a href="http://some-branch.staging.movielala.com">http://some-branch.staging.movielala.com</a> has been deployed!')
    end

    it "has proper update message" do
      Integration.any_instance.stub(:path).and_return('/var/some-branch')
      expect(subject.message_for_update).to eql('<a href="http://some-branch.staging.movielala.com">http://some-branch.staging.movielala.com</a> has been updated!')
    end
  end
end
