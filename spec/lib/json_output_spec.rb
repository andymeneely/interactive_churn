require 'spec_helper'
require 'set'

describe "JsonOutput class" do

  # before(:each) do
  #   @directory_name = Dir.getwd + "/spec/samplerepo"
  #   ChurnStandard.root_directory = @directory_name
  # end

  it "returns churns metrics in json format for standard churn" do
    # ChurnStandard.root_directory = @directory_name
    churn = ChurnStandard.new(Dir.getwd + "/spec/samplerepo")
    # expect(JsonOutput.standard ChurnStandard.compute).to eq( "{\"Commits\":10,\"Total Churn\":66,\"Lines added\":47,\"Lines deleted\":19}")
    expect(JsonOutput.standard churn.compute).to eq( "{\"Standard churn\":66}")
  end

  it "returns churns metrics in json format for affected churn" do
    achurn = ChurnAffectedLine.new(Dir.getwd + "/spec/samplerepo")
    expect(JsonOutput.affected_lines achurn.compute).to eq( "{\"Affected lines\":14}")
  end

  it "returns churns metrics in json format for interactive churn" do
    ichurn = ChurnInteractive.new(Dir.getwd + "/spec/samplerepo")
    expect(JsonOutput.interactive_lines ichurn.compute).to eq( "{\"Interactive lines\":16}")
  end
end
