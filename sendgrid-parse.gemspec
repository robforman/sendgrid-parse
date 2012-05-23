# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sendgrid-parse/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rob Forman"]
  gem.email         = ["rob@robforman.com"]
  gem.description   = %q{Library to dynamically set or change the encoding type for fields, ie params from SendGrid Parse API.}
  gem.summary       = %q{Library to dynamically set or change the encoding type for fields, ie params from SendGrid Parse API.}
  gem.homepage      = "https://github.com/robforman/sendgrid-parse"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sendgrid-parse"
  gem.require_paths = ["lib"]
  gem.version       = Sendgrid::Parse::VERSION
  gem.add_dependency "json", "~> 1.7.3"
  gem.add_development_dependency "rspec", "~> 2.10.0"
  gem.add_development_dependency "active_support", "~> 3.0.0"
end
