require 'spec_helper'
require 'set'

describe "ChurnStandard class" do

  before(:each) do
    @churn = ChurnStandard.new(Dir.getwd + "/spec/samplerepo")
  end

  it "computes the interactive churn, number of commits, deletions, and insertions" do
    expect(@churn.compute).to eq(66)
    expect(@churn.commits).to eq(10)
    expect(@churn.deletions).to eq(19)
    expect(@churn.insertions).to eq(47)
  end

  it "computes churn with HEAD as default revision" do
    expect(@churn.compute).to eq(@churn.compute "HEAD")
  end

  it "computes the amount of inserted lines on a specific file for the entire history" do
    expect(@churn.compute("factorial.rb")).to eq(50)
    expect(@churn.insertions).to eq(34)
    expect(@churn.deletions).to eq(16)
  end

  # @todo This test should be for the base class Churn, but this would require
  # to add methods like Churn.capture_lines and Churn.count
  it "resets to zero the number of commits when the churn is computed" do
    2.times do
      expect(@churn.compute "HEAD^..HEAD").to eq(10)
      expect(@churn.commits).to eq(1)
    end
  end

  it "specifies what to print" do
    output_formatter = double("OutputFormatter")
    h = {"Commits:" => 0, "Standard churn:" => 0, "Deletions:" => 0, "Insertions:" => 0}
    expect(output_formatter).to receive(:print).with(h)
    @churn.print(output_formatter)
  end
end
