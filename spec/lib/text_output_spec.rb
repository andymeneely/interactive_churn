require 'spec_helper'
require 'set'

describe "TextOutput class" do

  before(:each) do
    @directory_name = Dir.getwd + "/spec/samplerepo"
    ChurnStandard.root_directory = @directory_name
  end

  it "returns a string with number of commits envolved, number of lines inserted and deleted, and the total churn" do
    expect(TextOutput.standard ChurnStandard.compute).to eq("Commits:       10\nTotal Churn:   66\nLines added:   47\nLines deleted: 19\n")
  end

  it "returns a string with number of affected lines" do
    expect(TextOutput.affected_lines ChurnAffectedLine.compute).to eq("Affected lines: 12\n")
  end

  it "returns a string with number of commits interactive lines" do
    expect(TextOutput.interactive_lines ChurnInteractive.compute).to eq("Interactive lines: 16\n")
  end
end
