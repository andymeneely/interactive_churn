require 'spec_helper'
require 'set'

describe "TextFormatter class" do

  it "returns a string with number of commits envolved, number of lines inserted and deleted, and the total churn" do
    churn = ChurnStandard.new(Dir.getwd + "/spec/samplerepo")
    # expect(TextFormatter.standard churn.compute).to eq("Commits:       10\nTotal Churn:   66\nLines added:   47\nLines deleted: 19\n")
    expect(TextFormatter.standard churn.compute).to eq("Standard churn: 66\n")
  end

  it "returns a string with number of affected lines" do
    achurn = ChurnAffectedLine.new(Dir.getwd + "/spec/samplerepo")
    expect(TextFormatter.affected_lines achurn.compute).to eq("Affected lines: 14\n")
  end

  it "returns a string with number of commits interactive lines" do
    ichurn = ChurnInteractive.new(Dir.getwd + "/spec/samplerepo")
    expect(TextFormatter.interactive_lines ichurn.compute).to eq("Interactive lines: 16\n")
  end
end
