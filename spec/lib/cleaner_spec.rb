require_relative '../../lib/cleaner'
require_relative '../spec_helper'

describe Cleaner do
  before do
    Commands.any_instance.stub(:run)
  end

  context "deploys" do
    subject { Cleaner.new.deploys }

    before do
      Dir.stub(:[]).and_return(['/some/place/deploy_1', '/some/place/runner', '/some/place/shared'])
    end

    it "has a list of all deploys" do
      expect(subject).to be_an(Array)
      expect(subject).to include('/some/place/deploy_1')
    end

    it "does not include shared" do
      expect(subject).to_not include('/some/place/shared')
    end

    it "does not include runner" do
      expect(subject).to_not include('/some/place/runner')
    end
  end

  context "run" do
    subject { Cleaner.new }

    before do
      Cleaner.any_instance.stub(:deploys).and_return(['/some/path'])
    end

    it "updates code for all deploys" do
      Commands.any_instance.should_receive(:pwd=).with('/some/path')
      Commands.any_instance.should_receive(:pull)
      subject.run
    end

    context "with update failure" do
      it "marks deploy for deletion" do
        Commands.any_instance.stub(:pull).and_return([1, "Couldn't find remote ref non-existent-branch"])
        subject.run
        expect(subject.deploys_to_remove).to eql(['/some/path'])
      end
    end

    it "runs command to delete deploys" do
      Cleaner.any_instance.stub(:deploys_to_remove).and_return(['/some/path', '/some/other/path'])
      Commands.any_instance.should_receive(:rm_rf).with(['/some/path', '/some/other/path'])
      subject.run
    end
  end
end
