require 'spec_helper'
require 'set'

describe "Churn class" do
  COMMAND_NAME = 'ichurn'

  it "has a constant that stores the command name" do
    expect(Churn::COMMAND_NAME).to match(/^#{COMMAND_NAME}$/)
  end

  it "raises an exception if not root_directory is especified" do
    msg = "#{COMMAND_NAME}: Not root directory specified"
    expect { Churn::compute }.to raise_error(StandardError, msg)
  end

  it "raises an exception if root_directory is not a directory" do
    directory_name = "not_a_directory"
    Churn::root_directory = directory_name
    msg = "#{COMMAND_NAME}: #{directory_name}: Not a directory"
    expect { Churn::compute }.to raise_error(StandardError, msg)
  end

  context "within a plain directory (non-git repo)" do
    before(:each) do
      @directory_name = Dir.getwd + "/.." + "/churn_test_directory"
      system("mkdir #{@directory_name}")
      Churn.root_directory = @directory_name
    end

    it "has the same current directory before and after checking expections" do
      cwd = Dir.getwd
      Churn.check_exceptions rescue
      expect(cwd).to eq(Dir.getwd)
    end

    it "raises an exception if the root_directory is not a git repository" do
      msg = "fatal: Not a git repository (or any of the parent directories): .git\n"
      expect { Churn.check_exceptions }.to raise_error(StandardError, msg)
    end

    after(:each) do
      system("rm -r -f #{@directory_name}")
    end
  end

  context "within a git repo with no commits" do
    before(:each) do
      @directory_name = Dir.getwd + "/.." + "/churn_test_directory"
      system("git init #{@directory_name} > /dev/null")
      Churn.root_directory = @directory_name
    end

    it "raises an exception when invoking compute method" do
      msg = "fatal: bad default revision 'HEAD'\n"
      expect { Churn.check_exceptions }.to raise_error(StandardError, msg)
    end

    after(:each) do
      system("rm -r -f #{@directory_name}")
    end
  end

  context "within a git repository" do
    before(:each) do
      @directory_name = Dir.getwd + "/spec/samplerepo"
      Churn.root_directory = @directory_name
    end

    it "raises an exception if using an unknown revision" do
      revision = "UNKNOWN_REVISION"
      msg = "fatal: ambiguous argument '#{revision}': unknown revision or path not in the working tree.\n" +
            "Use '--' to separate paths from revisions, like this:\n" +
            "'#{COMMAND_NAME} [<revision>...] -- [<file>...]'\n"
      expect { Churn.compute git_params: revision }.to raise_error(StandardError, msg)
    end

    it "raises an exception when using a file that does not exist" do
      file_name = "non-existent-file"
      msg = "fatal: ambiguous argument '#{file_name}': unknown revision or path not in the working tree.\n" +
            "Use '--' to separate paths from revisions, like this:\n" +
            "'#{COMMAND_NAME} [<revision>...] -- [<file>...]'\n"
      expect { Churn.compute git_params: file_name }.to raise_error(StandardError, msg)
    end
  end
end
