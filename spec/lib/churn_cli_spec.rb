require 'spec_helper'

describe "ChurnCLI class" do

  it "extracts git options from ARGV" do
    argv = ['--interactive-lines', '--json', 'HEAD^..HEAD', '--' ,'my_file.rb']
    expect(ChurnCLI.get_git_options_from argv).to eq('HEAD^..HEAD -- my_file.rb')
  end

  it "parses option from an array" do
    expect(ChurnCLI.parse ["--json", "--interactive-lines", "HEAD^^", "--", "my_file.rb"]).to eq(["--json", "--interactive-lines"])
  end

  it "raises an exception when churn command doesn't understand an --option" do
    msg = /invalid option: --not-understandable/
    expect{ ChurnCLI.parse ["--not-understandable", "HEAD^^"] }.to raise_error(OptionParser::InvalidOption, msg)
  end

  it "raises an exception if passing mutually exclusive params" do
    msg = /--affected-lines and --interactive-lines are mutually exclusive options/
    expect{ ChurnCLI.parse ["--affected-lines", "--interactive-lines", "HEAD^^"] }.to raise_error(OptionParser::ParseError, msg)
  end

  it "instanciates the right churn metric object given churn options" do
    [[], ChurnStandard,
     ['--interactive-lines'], ChurnInteractive,
     ['--json', '--affected-lines'], ChurnAffectedLine,].each_slice(2) do |churn_opts, churn_type|
      expect(ChurnCLI.get_churn churn_opts).to be_a(churn_type)
    end
  end

  it "returns the right class for printing format" do
    [['--json', '--affected-lines'], JsonFormatter,
     ['--interactive-lines'], TextFormatter ].each_slice(2) do |churn_opts, formatter_class|
      expect(ChurnCLI.get_formatter churn_opts).to eq(formatter_class)
    end
  end

  it "runs churn command with different params" do
    argv = ['--interactive-lines', '--json', 'HEAD^..HEAD', '--' ,'my_file.rb']
    git_opts = "HEAD^..HEAD -- my_file.rb"
    churn_opts = ['--interactive-lines', '--json']

    churn = double("ChurnXXX")
    allow(churn).to receive(:compute)
    allow(churn).to receive(:print)

    formatter = double("XXXFormatter")

    expect(ChurnCLI).to receive(:get_git_options_from).with(argv).once.and_return(git_opts)
    expect(ChurnCLI).to receive(:parse).with(argv).once.and_return(churn_opts)
    expect(ChurnCLI).to receive(:get_churn).with(churn_opts).once.and_return(churn)
    expect(ChurnCLI).to receive(:get_formatter).with(churn_opts).once.and_return(formatter)
    expect(churn).to receive(:compute).with(git_opts).once
    expect(churn).to receive(:print).with(formatter).once
    ChurnCLI.run_with(argv)
  end
end
