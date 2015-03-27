require 'text_formatter'
require 'json_formatter'
require 'churn_standard'
require 'churn_interactive'
require 'churn_affected_line'

# Class that represents the churn CLI and deals with the options to run the asked churn.
class ChurnCLI
  
  # A String storing the option for json format.
  JSON_FORMAT = "--json"
  # A String storing the option for computing interactive churn metric.
  INTERACTIVE_CHURN = "--interactive-lines"
  # A String storing the option for computing affected line churn metric.
  AFFECTED_LINE_CHURN = "--affected-lines"
  
  def self.print churn_opts, git_opts
    if churn_opts.include? INTERACTIVE_CHURN
      execute ChurnInteractive.new, churn_opts, git_opts
    elsif churn_opts.include? AFFECTED_LINE_CHURN
      execute ChurnAffectedLine.new, churn_opts, git_opts
    else
      execute ChurnStandard.new, churn_opts, git_opts
    end
  end

  def self.execute cs, churn_opts, git_opts
    cs.compute git_opts
    churn_opts.include?(JSON_FORMAT)? cs.print(JsonFormatter) : cs.print(TextFormatter)
  end
end
