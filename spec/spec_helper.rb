require 'simplecov'
require 'coveralls'
Coveralls.wear!

require 'churn'
require 'churn_affected_line'
require 'churn_interactive'
require 'churn_standard'
require 'text_formatter'
require 'json_formatter'
require 'git_cmd'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "spec/"
end
