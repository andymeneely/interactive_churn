require 'spec_helper'
require 'set'

describe "ChurnInteractive class" do
  before(:each) do
    @ichurn = ChurnInteractive.new(Dir.getwd + "/spec/samplerepo")
  end

  it "return a set of deleted lines given the data between @@" do
    results = [[1, 2], [4,4], nil, nil]
    ["@@ -1,2 +3,4 @@", "@@ -4 +12,109 @@", "@@ -4,0 +5,6 @@ class", "@@ -0,0 +1,7 @@"].each do |patch_at|
      match = patch_at.match(ChurnInteractive::PATCH_AT)
      expect(@ichurn.capture_lines match).to eq(results.shift)
    end
  end

  it "computes the interactive churn in a specific commit" do
    expect(@ichurn.compute "HEAD -- *.rb").to eq(16)
    expect(@ichurn.self_churn).to eq(3)
    expect(@ichurn.authors_affected).to eq(8)
  end
end
