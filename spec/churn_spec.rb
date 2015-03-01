require 'spec_helper'

describe "Churn class" do
  COMMAND_NAME = 'ichurn'

  it "has a constant that stores the command name" do
    expect(Churn::COMMAND_NAME).to match(/^#{COMMAND_NAME}$/)
  end

  it "raises an exception if root_directory is not a directory" do
    directory_name = "not_a_directory"
    Churn.root_directory = directory_name
    expect { Churn.compute }.to raise_error(StandardError, "#{COMMAND_NAME}: #{directory_name}: No such file or directory")
  end

  it "count insertions and deletions from the last line of git log --stat output" do
    expect(Churn.count_lines_from [" 1 file changed", " 2 insertions(+)", " 1 deletion(-)", " 1 file changed", " 1 insertion(+)"]).to include(insertions: 3, deletions: 1)
  end

  context "within a plain directory (non-git repo)" do
    before(:each) do
      @directory_name = Dir.getwd + "/.." + "/churn_test_directory"
      system("mkdir #{@directory_name}")
      Churn.root_directory = @directory_name
    end

    it "has the same current directory before and after call compute" do
      cwd = Dir.getwd
      Churn.compute rescue # => no matter if there is an exception, the expectation should be met
      expect(cwd).to eq(Dir.getwd)
    end

    it "raises an exception if the root_directory is not a git repository" do
      expect { Churn.compute }.to raise_error(StandardError, "#{COMMAND_NAME}: #{@directory_name}: fatal: Not a git repository (or any of the parent directories): .git")
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
      expect { Churn.compute }.to raise_error(StandardError, "#{COMMAND_NAME}: #{@directory_name}: fatal: bad default revision 'HEAD'")
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

    it "raises an exception if try to compute churn for an unknown revision" do
      revision = "UNKNOWN_REVISION"
      expect { Churn.compute revision: revision }.to raise_error(StandardError, "#{COMMAND_NAME}: fatal: ambiguous argument '#{revision}': unknown revision or path not in the working tree.")
    end

    it "computes churn with HEAD as default revision" do
      expect(Churn.compute).to eq(Churn.compute revision: "HEAD")
    end

    it "computes the number of inserted lines for the entire history and all files" do
      expect(Churn.compute[:insertions]).to eq(48)
    end

    it "computes the number of deleted lines for the entire history and all files" do
        expect(Churn.compute[:deletions]).to eq(20)
    end

    it "raises an exception when invoking compute method with a file that does not exist" do
      file_name = "non-existent-file"
      expect { Churn.compute file_name: file_name}.to raise_error(StandardError, "#{COMMAND_NAME}: fatal: ambiguous argument '#{file_name}': unknown revision or path not in the working tree.")
    end

    it "computes the amount of inserted lines on a specific file for the entire history" do
      expect(Churn.compute(file_name: "factorial.rb")[:insertions]).to eq(35)
      expect(Churn.compute(file_name: "test.rb")[:insertions] ).to eq(12)
    end

    it "computes the amount of deleted lines on a specific file for the entire history" do
      expect(Churn.compute(file_name: "factorial.rb")[:deletions]).to eq(17)
      expect(Churn.compute(file_name: "test.rb")[:deletions]).to eq(3)
    end

    it "computes the number of commits involved when calculating the churn" do
      expect(Churn.compute[:commits]).to eq(10)
    end

    it "returns an array with the history composed with the last lines of the output of `git log --stat` command" do
      file_a = "test.rb"
      expect(Churn.git_history_summary).to eq([" 2 files changed", " 8 insertions(+)", " 2 deletions(-)", " 2 files changed", " 6 insertions(+)", " 1 deletion(-)", " 2 files changed", " 7 insertions(+)", " 2 files changed", " 5 insertions(+)", " 3 deletions(-)", " 2 files changed", " 4 insertions(+)", " 3 deletions(-)", " 1 file changed", " 1 insertion(+)", " 1 file changed", " 2 insertions(+)", " 8 deletions(-)", " 1 file changed", " 7 insertions(+)", " 3 deletions(-)", " 1 file changed", " 7 insertions(+)", " 1 file changed", " 1 insertion(+)"])
    end

    it "returns a string with number of commits envolved, number of lines inserted and deleted, and the total churn" do
      expect(Churn.get_output).to eq("Commits:       10\nTotal Churn:   68\nLines added:   48\nLines deleted: 20\n")
    end

    it "computes churn between two revisions" do
      expect(Churn.compute(:revision => "HEAD^^..HEAD^")[:insertions]).to eq(6)
      expect(Churn.compute(:revision => "HEAD^..HEAD")[:insertions]).to eq(8)
      expect(Churn.compute(:revision => "HEAD^^..HEAD")[:insertions]).to eq(14)
    end

    it "computes churn between two revisions for a specific file" do
      expect(Churn.compute(revision: "HEAD^^..HEAD^", file_name: "factorial.rb")[:insertions]).to eq(5)
    end

  end

end
