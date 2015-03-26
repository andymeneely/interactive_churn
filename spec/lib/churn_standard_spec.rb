require 'spec_helper'
require 'set'

describe "ChurnStandard class" do

  before(:each) do
    @churn = ChurnStandard.new(Dir.getwd + "/spec/samplerepo")
  end

  it "computes the interactive churn in a specific commit" do
    expect(@churn.compute).to eq(66)
  end

  it "computes churn with HEAD as default revision" do
    expect(@churn.compute).to eq(@churn.compute "HEAD")
  end

  it "computes the number of commits, lines deleted, and lines inserted" do
    @churn.compute
    expect(@churn.commits).to eq(10)
    expect(@churn.insertions).to eq(47)
    expect(@churn.deletions).to eq(19)
  end

  # it "computes the number of inserted lines for the entire history and all files" do
  #   @churn.compute
  #   expect(@churn.insertions).to eq(47)
  # end

  #   it "computes the number of deleted lines for the entire history and all files" do
  #       expect(ChurnStandard.compute[:deletions]).to eq(19)
  #   end

  #   it "computes the amount of inserted lines on a specific file for the entire history" do
  #     expect(ChurnStandard.compute({git_params: "factorial.rb"})[:insertions]).to eq(34)
  #     expect(ChurnStandard.compute({git_params: "test.rb"})[:insertions] ).to eq(12)
  #   end

  #   it "computes the amount of deleted lines on a specific file for the entire history" do
  #     expect(ChurnStandard.compute({git_params: "factorial.rb"})[:deletions]).to eq(16)
  #     expect(ChurnStandard.compute({git_params: "test.rb"})[:deletions]).to eq(3)
  #   end

  #   it "computes the number of commits involved when calculating the churn" do
  #     expect(ChurnStandard.compute[:commits]).to eq(10)
  #   end

  #   it "returns an array with the history composed with the last lines of the output of `git log --stat` command" do
  #     expect(ChurnStandard.git_history_summary).to eq([" 2 files changed, 8 insertions(+), 2 deletions(-)", " 2 files changed, 6 insertions(+), 1 deletion(-)", " 2 files changed, 7 insertions(+)", " 2 files changed, 4 insertions(+), 2 deletions(-)", " 2 files changed, 4 insertions(+), 3 deletions(-)", " 1 file changed, 1 insertion(+)", " 1 file changed, 2 insertions(+), 8 deletions(-)", " 1 file changed, 7 insertions(+), 3 deletions(-)", " 1 file changed, 7 insertions(+)", " 1 file changed, 1 insertion(+)"])
  #   end

  #   # it "returns a string with number of commits envolved, number of lines inserted and deleted, and the total churn" do
  #   #   expect(TextOutput.standard ChurnStandard.compute).to eq("Commits:       10\nTotal Churn:   68\nLines added:   48\nLines deleted: 20\n")
  #   # end

  #   # it "returns churns metrics in json format" do
  #   #   expect(JsonOutput.standard ChurnStandard.compute).to eq( "{\"Commits\":10,\"Total Churn\":68,\"Lines added\":48,\"Lines deleted\":20}")
  #   # end

  #   it "computes churn between two revisions" do
  #     expect(ChurnStandard.compute({git_params: "HEAD^^..HEAD^"})[:insertions]).to eq(6)
  #     expect(ChurnStandard.compute({git_params: "HEAD^..HEAD"})[:insertions]).to eq(8)
  #     expect(ChurnStandard.compute({git_params: "HEAD^^..HEAD"})[:insertions]).to eq(14)
  #   end

  #   it "computes churn between two revisions for a specific file" do
  #     expect(ChurnStandard.compute({git_params: "HEAD^^..HEAD^ -- factorial.rb"})[:insertions]).to eq(5)
  #   end

  #   it "computes churn for a specific branch" do
  #     expect(ChurnStandard.compute[:insertions]).to eq(47)
  #     expect(ChurnStandard.compute({git_params: "origin/dev"})[:insertions]).to eq(56)
  #   end
  # end
end
