require 'spec_helper'
require 'set'

describe "JsonFormatter class" do
  it "prints as json" do
    h = {"Commits:" => 10, "Affected lines:" => 5}
    expect(JsonFormatter.print(h)).to eq("{\"Commits:\":10,\"Affected lines:\":5}")
  end

  it "returns churns metrics in json format for standard churn" do
    churn = ChurnStandard.new(Dir.getwd + "/spec/samplerepo")
    expect(JsonFormatter.standard churn.compute).to eq( "{\"Standard churn\":66}")
  end

  it "returns churns metrics in json format for affected churn" do
    achurn = ChurnAffectedLine.new(Dir.getwd + "/spec/samplerepo")
    expect(JsonFormatter.affected_lines achurn.compute).to eq( "{\"Affected lines\":14}")
  end

  it "returns churns metrics in json format for interactive churn" do
    ichurn = ChurnInteractive.new(Dir.getwd + "/spec/samplerepo")
    expect(JsonFormatter.interactive_lines ichurn.compute).to eq( "{\"Interactive lines\":16}")
  end
end
