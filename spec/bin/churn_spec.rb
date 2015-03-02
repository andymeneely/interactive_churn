require 'spec_helper'

describe "Churn command" do
  it "prints churn metrics as text by default" do
    output = %x[ cd spec/samplerepo & churn ]
    expect(output).to match /^Commits:\s*\d*\sTotal Churn:\s*\d*\sLines added:\s*\d*\sLines deleted:\s*\d*\s$/
  end
end

