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
      expect { Churn.compute }.to raise_error(StandardError, "fatal: Not a git repository (or any of the parent directories): .git\n")
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
      expect { Churn.compute }.to raise_error(StandardError, msg)
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
      msg = "fatal: ambiguous argument '#{revision}': unknown revision or path not in the working tree.\n" +
            "Use '--' to separate paths from revisions, like this:\n" +
            "'#{COMMAND_NAME} [<revision>...] -- [<file>...]'\n"
      expect { Churn.compute revision }.to raise_error(StandardError, msg)
    end

    it "computes churn with HEAD as default revision" do
      expect(Churn.compute).to eq(Churn.compute "HEAD")
    end

    it "computes the number of inserted lines for the entire history and all files" do
      expect(Churn.compute[:insertions]).to eq(48)
    end

    it "computes the number of deleted lines for the entire history and all files" do
        expect(Churn.compute[:deletions]).to eq(20)
    end

    it "raises an exception when invoking compute method with a file that does not exist" do
      file_name = "non-existent-file"
      msg = "fatal: ambiguous argument '#{file_name}': unknown revision or path not in the working tree.\n" +
            "Use '--' to separate paths from revisions, like this:\n" +
            "'#{COMMAND_NAME} [<revision>...] -- [<file>...]'\n"
      expect { Churn.compute file_name}.to raise_error(StandardError, msg)
    end

    it "computes the amount of inserted lines on a specific file for the entire history" do
      expect(Churn.compute("factorial.rb")[:insertions]).to eq(35)
      expect(Churn.compute("test.rb")[:insertions] ).to eq(12)
    end

    it "computes the amount of deleted lines on a specific file for the entire history" do
      expect(Churn.compute("factorial.rb")[:deletions]).to eq(17)
      expect(Churn.compute("test.rb")[:deletions]).to eq(3)
    end

    it "computes the number of commits involved when calculating the churn" do
      expect(Churn.compute[:commits]).to eq(10)
    end

    it "returns an array with the history composed with the last lines of the output of `git log --stat` command" do
      expect(Churn.git_history_summary).to eq([" 2 files changed", " 8 insertions(+)", " 2 deletions(-)", " 2 files changed", " 6 insertions(+)", " 1 deletion(-)", " 2 files changed", " 7 insertions(+)", " 2 files changed", " 5 insertions(+)", " 3 deletions(-)", " 2 files changed", " 4 insertions(+)", " 3 deletions(-)", " 1 file changed", " 1 insertion(+)", " 1 file changed", " 2 insertions(+)", " 8 deletions(-)", " 1 file changed", " 7 insertions(+)", " 3 deletions(-)", " 1 file changed", " 7 insertions(+)", " 1 file changed", " 1 insertion(+)"])
    end

    it "returns a string with number of commits envolved, number of lines inserted and deleted, and the total churn" do
      expect(Churn.get_output).to eq("Commits:       10\nTotal Churn:   68\nLines added:   48\nLines deleted: 20\n")
    end

    it "returns churns metrics in json format" do
      expect(Churn.get_output "", {format: "--json"}).to eq( "{\"Commits\":10,\"Total Churn\":68,\"Lines added\":48,\"Lines deleted\":20}")
    end

    it "computes churn between two revisions" do
      expect(Churn.compute("HEAD^^..HEAD^")[:insertions]).to eq(6)
      expect(Churn.compute("HEAD^..HEAD")[:insertions]).to eq(8)
      expect(Churn.compute("HEAD^^..HEAD")[:insertions]).to eq(14)
    end

    it "computes churn between two revisions for a specific file" do
      expect(Churn.compute("HEAD^^..HEAD^ -- factorial.rb")[:insertions]).to eq(5)
    end

    it "computes churn for a specific branch" do
      system("cd spec/samplerepo && " +
             "git checkout dev && "+
             "git checkout master", :out => "")
      expect(Churn.compute[:insertions]).to eq(48)
      expect(Churn.compute("dev")[:insertions]).to eq(57)
    end

  end

end
