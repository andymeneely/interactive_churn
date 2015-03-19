require 'spec_helper'
require 'set'

describe "ChurnInteractive class" do

  context "within a git repository" do
    before(:each) do
      @directory_name = Dir.getwd + "/spec/samplerepo"
      ChurnInteractive.root_directory = @directory_name
    end

    it "returns an array of string with commit, author, filename, and data between @@" do
      result = ["commit e922313c15bb8496de0c4debdf71f7535ccda2a1",
                "Author: James <james@email.edu>",
                "diff --git a/factorial.rb b/factorial.rb",
                "@@ -4,0 +5,4 @@ class Factorial",
                "diff --git a/test.rb b/test.rb",
                "@@ -3,0 +4,3 @@ require './factorial'",
                "commit c1d52a4903e52714ae002d05916fdc6ef863f44f",
                "Author: Jill <jill@email.edu>",
                "diff --git a/factorial.rb b/factorial.rb",
                "@@ -1,0 +2,5 @@ class Factorial",
                "diff --git a/test.rb b/test.rb",
                "@@ -5 +5 @@ require './factorial'"]
      expect(ChurnInteractive.git_history "HEAD^^^..HEAD^").to eq(result)
    end

    it "return a set of deleted lines given the data between @@" do
      expect(ChurnInteractive::get_array_of_start_end_delition "@@ -1,2 +3,4 @@").to eq([1, 2])
      expect(ChurnInteractive::get_array_of_start_end_delition "@@ -1 +3,2 @@").to eq([1,1])
      expect(ChurnInteractive::get_array_of_start_end_delition "@@ -9 +8,0 @@").to eq([9,9])
      expect(ChurnInteractive::get_array_of_start_end_delition "@@ -4,0 +5,6 @@ class").to eq(nil)
      expect(ChurnInteractive::get_array_of_start_end_delition "@@ -0,0 +1,7 @@").to eq(nil)
    end

    it "computes number of affected lines" do
      expect(ChurnInteractive::compute({git_params: "HEAD^^^^^^^^^..HEAD^^^^^"})[:interactive_lines]).to eq(9)
      expect(ChurnInteractive::compute(compute: "--affected-lines")[:interactive_lines]).to eq(16)
    end

  end

end
