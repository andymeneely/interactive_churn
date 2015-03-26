require 'spec_helper'
require 'set'

describe "Churn class" do
  COMMAND_NAME = 'ichurn'

  it "has a constant that stores the command name" do
    expect(Churn::COMMAND_NAME).to match(/^#{COMMAND_NAME}$/)
  end

  before(:each) do
    @churn = Churn.new(Dir.getwd + "/spec/samplerepo")
  end

  it "return an array of arrays with delition position, delition length, insertion position, and insertion length" do
    results = [[1, 2, 3, 4], [4, 1, 12, 109], [4, 0, 5, 6,], [0, 0, 1, 7]]
    ["@@ -1,2 +3,4 @@", "@@ -4 +12,109 @@", "@@ -4,0 +5,6 @@ class", "@@ -0,0 +1,7 @@"].each do |patch_at|
      match = patch_at.match(Churn::PATCH_AT)
      expect(@churn.capture_all_lines match).to eq(results.shift)
    end
  end
end
