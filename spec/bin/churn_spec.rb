require 'spec_helper'

describe "Churn command" do
  it "returns the help when -help is passed" do
    msg = "churn [--affected-lines | --interactive-lines] [--json] [any git param]\n" +
          "Command line that returns churn related metrics.\n" +
          "        --json                       Return metric in json format\n" +
          "        --affected-lines             Compute affected lines\n" +
          "        --interactive-lines          Compute interactive lines\n"
    output = %x[ ichurn --help]
    expect(output).to eq(msg)
  end
end
