require 'spec_helper'
require 'set'

describe "ChurnAffectedLine class" do

  before(:each) do
    @achurn = ChurnAffectedLine.new(Dir.getwd + "/spec/samplerepo")
  end

  it "return a set of deleted lines given the data between @@" do
    results = [[Set.new(1..2), Set.new(3..6)], [Set.new(4..4), Set.new(12..120)], [Set.new, Set.new(5..10)], [Set.new, Set.new(1..7)]]
    ["@@ -1,2 +3,4 @@", "@@ -4 +12,109 @@", "@@ -4,0 +5,6 @@ class", "@@ -0,0 +1,7 @@"].each do |patch_at|
      match = patch_at.match(ChurnAffectedLine::PATCH_AT)
      expect(@achurn.capture_lines match).to eq(results.shift)
    end
  end

  it "computes number of affected lines" do
    expect(@achurn.compute("HEAD^^^^^^^^^..HEAD^^^^^^")).to eq(9)
    expect(@achurn.compute).to eq(14)
  end

  it "specifies what to print" do
    output_formatter = double("OutputFormater")
    h = {"Commits:" => 0, "Affected lines churn:" => 0}
    expect(output_formatter).to receive(:print).with(h)
    @achurn.print(output_formatter)
  end
end
