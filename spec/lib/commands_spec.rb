require_relative '../../lib/commands'
require_relative '../spec_helper'

describe Commands do
  context "fire" do
    it "runs the command with options" do
      Commands.any_instance.should_receive(:some_command)
      commands =  Commands.fire(run: :some_command, in: 'some_path')
      expect(commands).to be_a(Commands)
      expect(commands.pwd).to eql('some_path')
    end
  end

  context "create command" do
    it "clones repository" do
      expected_cmd = 'git clone git@bitbucket.org:movielalainc/web.git --branch features/awesome-feature --single-branch some_path'
      Commands.any_instance.should_receive(:cd_into_target)
      Commands.any_instance.stub(:link_db_config)
      Commands.any_instance.should_receive(:system).with(expected_cmd)
      Commands.fire(run: :create, in: 'some_path', branch: 'features/awesome-feature')
    end

     it "links the db config" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:system)
      Commands.any_instance.should_receive(:link_db_config)
      Commands.fire(run: :create, in: 'some_path', branch: 'features/awesome-feature')
     end
  end

  context "update command" do
    it "pulls from the branch" do
      expected_cmd = 'git pull origin features/awesome-feature'
      Commands.any_instance.should_receive(:cd_into_target)
      Commands.any_instance.stub(:touch_restart)
      Commands.any_instance.should_receive(:system).with(expected_cmd)
      Commands.fire(run: :update, in: 'some_path', branch: 'features/awesome-feature')
    end

    it "restarts the server" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:system)
      Commands.any_instance.should_receive(:touch_restart)
      Commands.fire(run: :update, in: 'some_path', branch: 'features/awesome-feature')
    end
  end
end
