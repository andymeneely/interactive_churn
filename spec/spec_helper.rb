require 'simplecov'
require 'coveralls'
Coveralls.wear!

require_relative '../lib/churn'
require_relative '../lib/churn_affected_line'
require_relative '../lib/churn_interactive'
require_relative '../lib/churn_standard'
require_relative '../lib/text_output'
require_relative '../lib/json_output'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start
