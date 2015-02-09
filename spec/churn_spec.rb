require 'spec_helper'

describe "Churn" do
  it "has a constant that stores the command name" do
    expect(Churn::COMMAND_NAME).to match(/^ichurn$/)
  end

  it "raises an exception if root_directory is not a directory" do
    directory_name = "not_a_directory"
    Churn.root_directory = directory_name
    expect { Churn.compute }.to raise_error(StandardError, "ichurn: #{directory_name}: No such file or directory")
  end

  it "has the same current directory before and after call compute" do
    cwd = Dir.getwd
    directory_name = Dir.getwd + "/.." + "/churn_test_directory"
    system("mkdir #{directory_name}")

    Churn.root_directory = directory_name
    Churn.compute rescue # => no matter if there is an exception, the expectation should be met
    expect(cwd).to eq(Dir.getwd)

    system("rm -r -f #{directory_name}")
  end

  it "raises an exception if the root_directory is not a git repository" do
    directory_name = Dir.getwd + "/.." + "/churn_test_directory"
    system("mkdir #{directory_name}")

    Churn.root_directory = directory_name
    expect { Churn.compute }.to raise_error(StandardError, "ichurn: #{directory_name}: fatal: Not a git repository (or any of the parent directories): .git")

    system("rm -r -f #{directory_name}")
  end

  it "raises an exception if the root_directory is a git repository with no commits" do
    directory_name = Dir.getwd + "/.." + "/churn_test_directory"
    system("mkdir #{directory_name}")
    system("git init #{directory_name}")

    Churn.root_directory = directory_name
    expect { Churn.compute }.to raise_error(StandardError, "ichurn: #{directory_name}: fatal: bad default revision 'HEAD'")

    system("rm -r -f #{directory_name}")
  end

end
