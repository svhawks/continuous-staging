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
    after do
      Commands.fire(run: :create, in: 'some_path', branch: 'features/awesome-feature')
    end

    it "changes directory to given path" do
      Commands.any_instance.stub(:link_db_config)
      Commands.any_instance.stub(:clone)
      Commands.any_instance.stub(:update_submodule)
      Commands.any_instance.should_receive(:cd_into_target)
    end

    it "clones repository" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:link_db_config)
      Commands.any_instance.stub(:update_submodule)
      Commands.any_instance.should_receive(:clone)
    end

    it "updates submodules" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:link_db_config)
      Commands.any_instance.stub(:clone)
      Commands.any_instance.should_receive(:update_submodule)
    end

     it "links the db config" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:clone)
      Commands.any_instance.stub(:update_submodule)
      Commands.any_instance.should_receive(:link_db_config)
     end
  end

  context "update command" do
    after do
      Commands.fire(run: :update, in: 'some_path', branch: 'features/awesome-feature')
    end

    it "cds into target" do
      Commands.any_instance.stub(:touch_restart)
      Commands.any_instance.stub(:pull)
      Commands.any_instance.stub(:update_submodule)
      Commands.any_instance.should_receive(:cd_into_target)
    end

    it "pulls from the branch" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:touch_restart)
      Commands.any_instance.stub(:update_submodule)
      Commands.any_instance.should_receive(:pull)
    end

    it "restarts the server" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:pull)
      Commands.any_instance.stub(:update_submodule)
      Commands.any_instance.should_receive(:touch_restart)
    end

    it "updates submodules" do
      Commands.any_instance.stub(:cd_into_target)
      Commands.any_instance.stub(:pull)
      Commands.any_instance.stub(:touch_restart)
      Commands.any_instance.should_receive(:update_submodule)
    end
  end


  context "instance methods" do
    subject{ Commands.new }

    before do
      Commands.any_instance.stub(:branch).and_return('some-branch')
    end

    context "update_submodule" do
      it "runs the submodule update commands" do
        expected_cmd = 'git submodule init && git submodule update'
        Commands.any_instance.should_receive(:system).with(expected_cmd)
        subject.update_submodule
      end
    end

    context "clone" do
      it "runs the clone command" do
        Commands.any_instance.stub(:pwd).and_return('some_path')
        expected_cmd = 'git clone git@bitbucket.org:movielalainc/web.git --branch some-branch --single-branch some_path'
        Commands.any_instance.should_receive(:system).with(expected_cmd)
        subject.clone
      end
    end

    context "pull" do
      it "runs the pull command" do
        expected_cmd = 'git pull origin some-branch'
        Commands.any_instance.should_receive(:system).with(expected_cmd)
        subject.pull
      end
    end

    context "cd_into_target" do
      before do
        Commands.any_instance.stub(:pwd).and_return('some_path')
      end

      it "runs command to change directory" do
        subject.should_receive(:system).once.with('mkdir -p some_path').ordered
        subject.should_receive(:system).once.with('cd some_path').ordered
        subject.cd_into_target
      end
    end
  end
end
