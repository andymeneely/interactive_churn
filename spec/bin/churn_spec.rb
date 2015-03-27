require 'spec_helper'

describe "Churn command" do
  it "prints churn metrics as text by default" do
    output = %x[ churn ]
    expect(output).to match /^Commits:\s*\d*\nStandard churn:\s*\d*\nDeletions:\s*\d*\nInsertions:\s*\d*\s$/
  end
  it "prints churn metrics as json" do
    output = %x[ churn --json]
    expect(output).to match /^{\"Commits:\":\d+,\"Standard churn:\":\d+,\"Deletions:\":\d+,\"Insertions:\":\d+}\n/
  end
  it "prints affected lines as text by default" do
    output = %x[ churn --affected-lines ]
    expect(output).to match /^Commits:\s+\d+\nAffected lines churn:\s+\d+\n$/
  end
  it "prints affected lines as json" do
    output = %x[ churn --affected-lines --json]
    expect(output).to match /^{\"Commits:\":\d+,\"Affected lines churn:\":\d+}\n$/
    # expect(output).to match /^{\"Affected lines\":\d*}\n$/
  end
  it "prints interactive lines as text by default" do
    output = %x[ churn --interactive-lines ]
    expect(output).to match /Commits:\s+\d+\nInteractive churn:\s+\d+\nSefl churn:\s+\d+\nAuthors affected:\s+\d+\n/
  end
  it "prints interactive lines as json" do
    output = %x[ churn --interactive-lines --json]
    expect(output).to match /^{\"Commits:\":\d+,\"Interactive churn:\":\d+,\"Sefl churn:\":\d+,\"Authors affected:\":\d+}\n$/
  end
  it "returns an error when --interactive-lines --affected-lines are passed" do
    msg = "parse error: --affected-lines and --interactive-lines are mutually exclusive\n" +
          "(-h or --help will show valid options)\n"
    output = %x[ churn --interactive-lines --affected-lines]
    expect(output).to eq(msg)
  end
  it "returns the help when -help is passed" do
    msg = "churn [--affected-lines | --interactive-lines] [--json] [any git params]\n" +
          "Command line that returns churn related metrics.\n" +
          "        --json                       Return metric in json format\n" +
          "        --affected-lines             Compute affected lines\n" +
          "        --interactive-lines          Compute interactive lines\n" +
          "exit\n"
    output = %x[ churn --help]
    expect(output).to eq(msg)
  end
end
