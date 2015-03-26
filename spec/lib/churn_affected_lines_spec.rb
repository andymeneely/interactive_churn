require 'spec_helper'
require 'set'

describe "ChurnAffectedLine class" do
  context "using objects" do


    before(:each) do
      @achurn = ChurnAffectedLine.new(Dir.getwd + "/spec/samplerepo")
    end

    it "return a set of deleted lines given the data between @@" do
      results = [[Set.new(1..2), Set.new(3..6)], [Set.new(4..4), Set.new(12..120)], [Set.new, Set.new(5..10)], [Set.new, Set.new(1..7)]]
      ["@@ -1,2 +3,4 @@", "@@ -4 +12,109 @@", "@@ -4,0 +5,6 @@ class", "@@ -0,0 +1,7 @@"].each do |patch_at|
        match = patch_at.match(ChurnAffectedLine::PATCH_AT)
        expect(@achurn.capture_lines match).to eq(results.shift)
      end
    end

    it "computes number of affected lines" do
      expect(@achurn.compute("HEAD^^^^^^^^^..HEAD^^^^^^")).to eq(9)
      expect(@achurn.compute).to eq(14)
    end

  end


  # context "within a git repository" do
  #   before(:each) do
  #     @directory_name = Dir.getwd + "/spec/samplerepo"
  #     ChurnAffectedLine.root_directory = @directory_name
  #   end

  #   it "returns an array of string with author, filename, and data between @@" do
  #     result = ["Author: James <james@email.edu>",
  #               "diff --git a/factorial.rb b/factorial.rb",
  #               "@@ -4,0 +5,4 @@ class Factorial",
  #               "diff --git a/test.rb b/test.rb",
  #               "@@ -3,0 +4,3 @@ require './factorial'",
  #               "Author: Jill <jill@email.edu>",
  #               "diff --git a/factorial.rb b/factorial.rb",
  #               "@@ -1,0 +2,5 @@ class Factorial",
  #               "diff --git a/test.rb b/test.rb",
  #               "@@ -5 +5 @@ require './factorial'"]
  #     expect(ChurnAffectedLine.git_history "HEAD^^^..HEAD^").to eq(result)
  #   end

  #   it "return a set given the data between @@" do
  #     expect(ChurnAffectedLine::get_set_from "@@ -1,2 +3,4 @@").to eq(Set.new [1, 2, 3, 4, 5, 6])
  #     expect(ChurnAffectedLine::get_set_from "@@ -1 +3,2 @@").to eq(Set.new [1, 3, 4])
  #     expect(ChurnAffectedLine::get_set_from "@@ -9 +8,0 @@").to eq(Set.new [9])
  #     expect(ChurnAffectedLine::get_set_from "@@ -1 +1 @@").to eq(Set.new [1])
  #     expect(ChurnAffectedLine::get_set_from "@@ -4,0 +5,6 @@ class").to eq(Set.new [5, 6, 7, 8, 9, 10])
  #     expect(ChurnAffectedLine::get_set_from "@@ -4,0 +5 @@ class").to eq(Set.new [5])
  #   end

  #   it "computes number of affected lines" do
  #     expect(ChurnAffectedLine::compute(git_params: "HEAD^^^^^^^^^..HEAD^^^^^^", compute: "--affected-lines")[:affected_lines]).to eq(9)
  #     expect(ChurnAffectedLine::compute(compute: "--affected-lines")[:affected_lines]).to eq(12)
  #   end

  # end

end
