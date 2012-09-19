# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'go_daddy_api/version'

Gem::Specification.new do |gem|
  gem.name          = 'go_daddy_api'
  gem.version       = GoDaddyApi::VERSION
  gem.authors       = ["Weston Platter"]  
  gem.email         = ["westonplatter@gmail.com"]
  gem.description   = %q{Automates Go Daddy account management}
  gem.summary       = %q{Automates Go Daddy account management: more to come later}
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'watir-webdriver'
  gem.add_dependency 'mongo_mapper'
end
