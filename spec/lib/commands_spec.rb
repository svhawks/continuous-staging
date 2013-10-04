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

  context "create update commands" do
    subject{ Commands.new }

    context "create command" do
      it "runs all commands in order" do
        subject.should_receive(:ensure_working_directory).ordered
        subject.should_receive(:clone).ordered
        subject.should_receive(:update_submodule).ordered
        subject.should_receive(:bundle).ordered
        subject.should_receive(:link_db_config).ordered
        subject.should_receive(:link_shared_log).ordered
        subject.should_receive(:ensure_proper_permissions).ordered
        subject.should_receive(:broadcast_new_deploy_on_hipchat).ordered
        subject.create
      end
    end

    context "update command" do
      it "updates bundle" do
        subject.should_receive(:ensure_working_directory).ordered
        subject.should_receive(:pull).ordered
        subject.should_receive(:update_submodule).ordered
        subject.should_receive(:bundle).ordered
        subject.should_receive(:link_db_config).ordered
        subject.should_receive(:link_shared_log).ordered
        subject.should_receive(:ensure_proper_permissions).ordered
        subject.should_receive(:touch_restart).ordered
        subject.should_receive(:broadcast_update_on_hipchat).ordered
        subject.update
      end
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
        Commands.any_instance.should_receive(:run).with(expected_cmd)
        subject.update_submodule
      end
    end

    context "clone" do
      it "runs the clone command" do
        Commands.any_instance.stub(:pwd).and_return('some_path')
        expected_cmd = 'git clone git@bitbucket.org:movielalainc/web.git --branch some-branch --single-branch some_path'
        Commands.any_instance.should_receive(:run).with(expected_cmd)
        subject.clone
      end
    end

    context "pull" do
      it "runs the pull command" do
        expected_cmd = 'git reset HEAD && git checkout . && git clean -f -d && git pull origin some-branch'
        Commands.any_instance.should_receive(:run).with(expected_cmd)
        subject.pull
      end
    end

    context "link_shared_log" do
      it "symlinks shared resque config" do
        Commands.any_instance.stub(:pwd).and_return('root_path')
        expected_cmd = 'ln -nfs /var/www/vhosts/movielala.com/staging/shared/log root_path/log'
        Commands.any_instance.should_receive(:run).with(expected_cmd)
        subject.link_shared_log
      end
    end

    context "link_db_config" do
      it "symlinks shared db config" do
        Commands.any_instance.stub(:pwd).and_return('root_path')
        expected_cmd = 'ln -nfs /var/www/vhosts/movielala.com/staging/shared/config/database.yml root_path/config/database.yml'
        Commands.any_instance.should_receive(:run).with(expected_cmd)
        subject.link_db_config
      end
    end

    context "ensure_working_directory" do
      before do
        Commands.any_instance.stub(:pwd).and_return('some_path')
      end

      it "runs command to change directory" do
        FileUtils.should_receive(:mkdir_p).once.with('some_path')
        subject.ensure_working_directory
      end
    end

    context "bundle" do
      it "runs command to bundle" do
        Commands.any_instance.stub(:pwd).and_return('some_path')
        subject.should_receive(:run_with_clean_env).once.with('bundle --path /var/www/vhosts/movielala.com/staging/shared/bundle --gemfile some_path/Gemfile --without test development')
        subject.bundle
      end
    end

    context "ensure_proper_permissions" do
      it "runs command to ensure proper permissions" do
        Commands.any_instance.stub(:pwd).and_return('some_path')
        subject.should_receive(:run).once.with('chown -R www-data:www-data some_path')
        subject.ensure_proper_permissions
      end
    end

    context "rm_rf" do
      it "only runs command if folder are present" do
        Commands.any_instance.stub(:staging_root).and_return('some_path')
        subject.should_receive(:run).never
        subject.rm_rf([])
      end

      it "runs command to delete all folders" do
        Commands.any_instance.stub(:staging_root).and_return('some_path')
        subject.should_receive(:run).once.with('rm -rf /some/path /some/other/path', 'some_path')
        subject.rm_rf(['/some/path', '/some/other/path'])
      end
    end

    context "broadcast helpers" do
      before do
        subject.stub(:pwd).and_return('/some/path')
      end

      context "broadcast_new_deploy_on_hipchat" do
        it "delegates to the hipchat integration" do
          HipChatIntegration.should_receive(:update).with('/some/path', :new_deploy)
          subject.broadcast_new_deploy_on_hipchat
        end
      end

      context "broadcast_update_on_hipchat" do
        it "delegates to the hipchat integration" do
          HipChatIntegration.should_receive(:update).with('/some/path', :update)
          subject.broadcast_update_on_hipchat
        end
      end
    end

    context "touch_restart" do
      it "touches restart.txt and warms up the app" do
        subject.stub(:pwd).and_return('/some/awesome-feature')
        subject.should_receive(:run).once.with('touch tmp/restart.txt && curl http://awesome-feature.staging.movielala.com > /dev/null')
        subject.touch_restart
      end
    end
  end
end
