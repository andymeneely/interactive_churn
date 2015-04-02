require 'optparse'
require 'interactive_churn/version'
require 'text_formatter'
require 'json_formatter'
require 'churn_standard'
require 'churn_interactive'
require 'churn_affected_line'

# Class that represents the churn CLI and deals with the options to run the asked churn.
class ChurnCLI

  # Options that churn command understand
  CHURN_OPTS = ['-j', '--json', '-a', '--affected-lines', '-i', '--interactive-lines']
  # A String storing the option for json format.
  JSON_FORMAT = "--json"
  # A String storing the option for computing interactive churn metric.
  INTERACTIVE_CHURN = "--interactive-lines"
  # A String storing the option for computing affected line churn metric.
  AFFECTED_LINE_CHURN = "--affected-lines"
  
  # Gets the right churn object based on churn options.
  # @param churn_opts [Array<String>] Array of strings with churn options.
  # @return [Churn] An instance of a concrete Churn.
  def self.get_churn churn_opts
    if churn_opts.include? INTERACTIVE_CHURN
      ChurnInteractive.new
    elsif churn_opts.include? AFFECTED_LINE_CHURN
      ChurnAffectedLine.new
    else
      ChurnStandard.new
    end
  end

  # Gets the right formatter class object based on churn options.
  # @param churn_opts [Array<String>] Array of string with churn options.
  # @return [Class] A formatter class object: JsonFormatter or TextFormatter.
  def self.get_formatter churn_opts
    if churn_opts.include? JSON_FORMAT
      JsonFormatter
    else
      TextFormatter
    end
  end

  # Runs the churn metric selected in the params passed in argv and returns the result in the specified format.
  # @param argv [Array< String>] Array that contains params given to churn command.
  # @return [String] A string with the result.
  def self.run_with argv
    git_opts = get_git_options_from argv
    churn_opts = parse argv
    churn = get_churn churn_opts
    formatter = get_formatter churn_opts
    churn.compute git_opts
    churn.print formatter
  end

  # Extract unrelated churn options.
  # @param argv [Array< String>] Array that contains params given to churn command.
  def self.get_git_options_from argv
    (argv - CHURN_OPTS).reduce{ |a, b| a + " " + b} || ""
  end

  # Parses params given to churn command line. It uses optparse gem.
  # @param argv [Array<String>] Array of string with params. It represents the ARGV params given to churn command line.
  # @return [Array<String>] An array of string with churn options.
  # @raise [OptionParser] It raises OptionParser error like ParseError or InvalidOption.
  def self.parse argv
    churn_opts = []
    OptionParser.new do |opts|
      opts.banner = "churn [--affected-lines | --interactive-lines] [--json] [any git param]"
      opts.separator "Command line that returns churn related metrics."
      opts.version = InteractiveChurn::VERSION
      opts.on('--json', 'Return metric in json format')           { churn_opts << '--json' }
      opts.on('--affected-lines', 'Compute affected lines')       { churn_opts << '--affected-lines' }
      opts.on('--interactive-lines', 'Compute interactive lines') { churn_opts << '--interactive-lines' }
    end.parse!(argv)
    if (churn_opts & ['--affected-lines', '--interactive-lines']).size == 2
      raise OptionParser::ParseError.new("--affected-lines and --interactive-lines are mutually exclusive options")
    end
    churn_opts
  end
end
