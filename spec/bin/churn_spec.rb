require 'spec_helper'

describe "Churn command" do
  it "prints churn metrics as text by default" do
    output = %x[ cd spec/samplerepo & churn ]
    expect(output).to match /^Commits:\s*\d*\sTotal Churn:\s*\d*\sLines added:\s*\d*\sLines deleted:\s*\d*\s$/
  end
  it "prints churn metrics as json" do
    output = %x[ churn --json]
    expect(output).to match /^{\"Commits\":\d*,\"Total Churn\":\d*,\"Lines added\":\d*,\"Lines deleted\":\d*}\n$/
  end
end

