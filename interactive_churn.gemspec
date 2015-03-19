# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'interactive_churn/version'

Gem::Specification.new do |spec|
  spec.name          = "interactive_churn"
  spec.version       = InteractiveChurn::VERSION
  spec.authors       = ["Andy Meneely"]
  spec.email         = ["andy.meneely@gmail.com"]
  spec.summary       = %q{A suite of interactive code churn metrics}
  spec.description   = %q{A collecting of command-line scripts for collecting interactive code churn metrics}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]   

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "oj"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'coveralls'
end
