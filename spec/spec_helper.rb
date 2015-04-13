require 'simplecov'
require 'coveralls'
Coveralls.wear!

require 'interactive_churn/churn'
require 'interactive_churn/churn_affected_line'
require 'interactive_churn/churn_interactive'
require 'interactive_churn/churn_standard'
require 'interactive_churn/text_formatter'
require 'interactive_churn/json_formatter'
require 'interactive_churn/git_cmd'
require 'interactive_churn/churn_cli'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "spec/"
end
