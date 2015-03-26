require 'spec_helper'

describe "GitCmd class" do
  it "has cwd as default working directory" do
    cwd = Dir.getwd
    expect(GitCmd.new.wd).to eq(cwd)
  end

  context "within a plain directory (non-git repo)" do
    before(:each) do
      @directory_name = Dir.getwd + "/.." + "/churn_test_directory"
      system("mkdir #{@directory_name}")
      @git_cmd = GitCmd.new @directory_name
    end

    it "has the same current directory before and after checking expections" do
      cwd = Dir.getwd
      @git_cmd.log() rescue
      expect(cwd).to eq(Dir.getwd)
    end

    it "raises an exception if the root_directory is not a git repository" do
      msg = "fatal: Not a git repository (or any of the parent directories): .git\n"
      expect { @git_cmd.log }.to raise_error(StandardError, msg)
    end

    after(:each) do
      system("rm -r -f #{@directory_name}")
    end
  end

  context "within a git repo with no commits" do
    before(:each) do
      @directory_name = Dir.getwd + "/.." + "/churn_test_directory"
      system("git init #{@directory_name} > /dev/null")
      @git_cmd = GitCmd.new @directory_name
    end

    it "raises an exception when invoking compute method" do
      msg = "fatal: bad default revision 'HEAD'\n"
      expect { @git_cmd.log }.to raise_error(StandardError, msg)
    end

    after(:each) do
      system("rm -r -f #{@directory_name}")
    end
  end

  context "within /spec/samplerep git sample repo" do
    before(:each) do
      @git = GitCmd.new(Dir.getwd + "/spec/samplerepo")
    end

    it "returns logs from the repository" do
      result = "commit 05c29ae905f4fed857b39b6ba5708941183fa6b3\nAuthor: Héctor Valdecantos <hvaldecantos@gmail.com>\ndiff --git a/.ruby-version b/.ruby-version\n@@ -0,0 +1 @@\ncommit 2f7604deeb70efab9d66a70171cfd0fce2939836\nAuthor: John <john@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -0,0 +1,7 @@\ncommit 03f7f0b47bde717d3cf1472f55092748cd97c355\nAuthor: Jill <jill@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -1 +1 @@\n@@ -3 +3 @@ def factorial_of_five\n@@ -7 +7,5 @@ end\ncommit 53af22c77f4ca54208846f34d5867a18fc6a6abe\nAuthor: John <john@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -2,3 +2 @@ def factorial_of num\n@@ -7,5 +5 @@ end\ncommit 4919326ccfcafc5d06afe3e6fc8a5f932b23bda1\nAuthor: Jill <jill@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -5,0 +6 @@ end\ncommit 8257e3dbf71ca61bf4c1687edb141e01042124f3\nAuthor: James <james@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -4,3 +3,0 @@ end\ndiff --git a/test.rb b/test.rb\n@@ -0,0 +1,4 @@\ncommit c863f80f7240f9f01678410cedea3a46ecd9c224\nAuthor: James <james@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -1 +1,2 @@\n@@ -3,0 +5 @@ end\ndiff --git a/test.rb b/test.rb\n@@ -3 +3 @@ require './factorial'\ncommit e922313c15bb8496de0c4debdf71f7535ccda2a1\nAuthor: James <james@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -4,0 +5,4 @@ class Factorial\ndiff --git a/test.rb b/test.rb\n@@ -3,0 +4,3 @@ require './factorial'\ncommit c1d52a4903e52714ae002d05916fdc6ef863f44f\nAuthor: Jill <jill@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -1,0 +2,5 @@ class Factorial\ndiff --git a/test.rb b/test.rb\n@@ -5 +5 @@ require './factorial'\ncommit abdce30d7fd47835a9f15d1cc85abd55ce17208d\nAuthor: Jill <jill@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -7 +7 @@ class Factorial\n@@ -10,0 +11,4 @@ class Factorial\ndiff --git a/test.rb b/test.rb\n@@ -3 +3,3 @@ require './factorial'\n"
      expect(@git.log).to eq(result)
    end

    it "returns logs from the repository given git options" do
      result = "commit abdce30d7fd47835a9f15d1cc85abd55ce17208d\nAuthor: Jill <jill@email.edu>\ndiff --git a/factorial.rb b/factorial.rb\n@@ -7 +7 @@ class Factorial\n@@ -10,0 +11,4 @@ class Factorial\ndiff --git a/test.rb b/test.rb\n@@ -3 +3,3 @@ require './factorial'\n"
      expect(@git.log "HEAD^..HEAD").to eq(result)
    end

    it "has the same current directory before and after invoking log method" do
      cwd = Dir.getwd
      revision = "UNKNOWN_REVISION"
      @git.log revision rescue
      expect(cwd).to eq(Dir.getwd)
    end

    it "raises an exception if options are not valid for git log command" do
      revision = "UNKNOWN_REVISION"
      msg = "fatal: ambiguous argument '#{revision}': unknown revision or path not in the working tree.\n" +
            "Use '--' to separate paths from revisions, like this:\n" +
            "'git <command> [<revision>...] -- [<file>...]'\n"
      expect{@git.log revision}.to raise_error(StandardError, msg)
    end

    it "returns the blame lines for a file" do
      result = "8257e3db (James 2015-02-27 13:11:09 -0500 1) require './factorial'\n8257e3db (James 2015-02-27 13:11:09 -0500 2) \nabdce30d (Jill  2015-02-27 14:20:16 -0500 3) (5..6).each{|n| puts Factorial.compute \"injecting\", n}\nabdce30d (Jill  2015-02-27 14:20:16 -0500 4) \nabdce30d (Jill  2015-02-27 14:20:16 -0500 5) puts Factorial.compute \"reducing\", 6\ne922313c (James 2015-02-27 13:33:25 -0500 6) \nc1d52a49 (Jill  2015-02-27 13:42:46 -0500 7) puts Factorial.compute \"recursively\", 6\ne922313c (James 2015-02-27 13:33:25 -0500 8) \n8257e3db (James 2015-02-27 13:11:09 -0500 9) puts \"end\"\n"
      expect(@git.blame "test.rb").to eq(result)
    end

    it "returns selected blame lines for a file in a specific commit" do
      result = "abdce30d (Jill  2015-02-27 14:20:16 -0500 3) (5..6).each{|n| puts Factorial.compute \"injecting\", n}\nabdce30d (Jill  2015-02-27 14:20:16 -0500 4) \ne922313c (James 2015-02-27 13:33:25 -0500 8) \n"
      expect(@git.blame "test.rb", "abdce30d7fd47835a9f15d1cc85abd55ce17208d", [[3,4], [8,8]]).to eq(result)
    end

    it "reduces an array of arrays into a string indicating lines to blame" do
      expect(GitCmd.reduce_to_string [[1,2],[4,6],[8,9]]).to eq("-L 1,2 -L 4,6 -L 8,9 ")
    end
  end
end
