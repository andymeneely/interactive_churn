require 'spec_helper'
require 'set'

describe "TextOutput class" do

  before(:each) do
    @directory_name = Dir.getwd + "/spec/samplerepo"
    ChurnStandard.root_directory = @directory_name
  end

  it "returns a string with number of commits envolved, number of lines inserted and deleted, and the total churn" do
    expect(TextOutput.standard ChurnStandard.compute).to eq("Commits:       10\nTotal Churn:   68\nLines added:   48\nLines deleted: 20\n")
  end

  it "returns a string with number of commits envolved, number of lines inserted and deleted, and the total churn" do
    expect(TextOutput.affected_lines ChurnAffectedLine.compute).to eq("Affected lines: 12\n")
  end
end
