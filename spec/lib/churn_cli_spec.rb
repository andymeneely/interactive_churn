require 'spec_helper'

describe "ChurnCLI class" do

  churn_opts = [[], ChurnStandard, TextFormatter,
                ["--json"], ChurnStandard, JsonFormatter,
                ["--interactive-lines"], ChurnInteractive, TextFormatter,
                ["--interactive-lines", "--json"], ChurnInteractive, JsonFormatter,
                ["--affected-lines"], ChurnAffectedLine, TextFormatter,
                ["--affected-lines", "--json"], ChurnAffectedLine, JsonFormatter]

  churn_opts.each_slice(3) do | churn_opts, churn_class, formatter_class|
    it "prints standard churn as text" do
      output = "output is tested in xxx_formater_spec.rb"
      git_opts = "any options"
      expect_any_instance_of(churn_class).to receive(:compute).with(git_opts).once
      expect_any_instance_of(churn_class).to receive(:print).with(formatter_class).once.and_return(output)
      expect(ChurnCLI.print(churn_opts, git_opts)).to eq(output)
    end
  end

  it "extracts git options from ARGV" do
    argv = ['--interactive-lines', '--json', 'HEAD^..HEAD', '--' ,'my_file.rb']
    expect(ChurnCLI.extract_unrelated_churn_options_from argv).to eq('HEAD^..HEAD -- my_file.rb')
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

  it "runs churn command with different params" do
    output = "output is tested in xxx_formater_spec.rb"
    argv = ['--interactive-lines', '--json', 'HEAD^..HEAD', '--' ,'my_file.rb']
    git_opts = "HEAD^..HEAD -- my_file.rb"
    churn_opts = ['--interactive-lines', '--json']

    expect(ChurnCLI).to receive(:extract_unrelated_churn_options_from).with(argv).once.and_return(git_opts)
    expect(ChurnCLI).to receive(:parse).with(argv).once.and_return(churn_opts)
    expect(ChurnCLI).to receive(:print).with(churn_opts, git_opts).once.and_return(output)
    expect(ChurnCLI.run_with(argv)).to eq(output)
  end
end
