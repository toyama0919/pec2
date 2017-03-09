# -*- encoding: utf-8 -*-

require File.expand_path('../lib/pec2/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "pec2"
  gem.version       = Pec2::VERSION
  gem.summary       = %q{run parallel ssh command. ec2 tag base operation.}
  gem.description   = %q{run parallel ssh command. ec2 tag base operation.}
  gem.license       = "MIT"
  gem.authors       = ["toyama0919"]
  gem.email         = "toyama0919@gmail.com"
  gem.homepage      = "https://github.com/toyama0919/pec2"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'thor'
  gem.add_dependency 'aws-sdk'
  gem.add_dependency 'hashie'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubygems-tasks'
  gem.add_development_dependency 'yard'
end
