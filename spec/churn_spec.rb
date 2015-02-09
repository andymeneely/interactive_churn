require 'spec_helper'

describe "Churn" do
  COMMAND_NAME = 'ichurn'

  it "has a constant that stores the command name" do
    expect(Churn::COMMAND_NAME).to match(/^#{COMMAND_NAME}$/)
  end

  it "raises an exception if root_directory is not a directory" do
    directory_name = "not_a_directory"
    Churn.root_directory = directory_name
    expect { Churn.compute }.to raise_error(StandardError, "#{COMMAND_NAME}: #{directory_name}: No such file or directory")
  end

  context "within an existing directory" do
    before(:each) do
      @directory_name = Dir.getwd + "/.." + "/churn_test_directory"
      system("mkdir #{@directory_name}")
      Churn.root_directory = @directory_name
    end

    it "has the same current directory before and after call compute" do
      cwd = Dir.getwd
      Churn.root_directory = @directory_name
      Churn.compute rescue # => no matter if there is an exception, the expectation should be met
      expect(cwd).to eq(Dir.getwd)
    end

    it "raises an exception if the root_directory is not a git repository" do
      Churn.root_directory = @directory_name
      expect { Churn.compute }.to raise_error(StandardError, "#{COMMAND_NAME}: #{@directory_name}: fatal: Not a git repository (or any of the parent directories): .git")
    end

    it "raises an exception if the root_directory is a git repository with no commits" do
      system("git init #{@directory_name}")

      Churn.root_directory = @directory_name
      expect { Churn.compute }.to raise_error(StandardError, "#{COMMAND_NAME}: #{@directory_name}: fatal: bad default revision 'HEAD'")
    end

    after(:each) do
      system("rm -r -f #{@directory_name}")
    end
  end

end
