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
end
