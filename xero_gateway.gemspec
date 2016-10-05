# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xero_gateway/version'

Gem::Specification.new do |s|
  s.name        = "xero_gateway"
  s.version     = XeroGateway::VERSION
  s.summary     = "Enables Ruby based applications to communicate with the Xero API"
  s.email       = ["me@nikwakelin.com", "jared@minutedock.com"]
  s.homepage    = "http://github.com/xero-gateway/xero_gateway"
  s.description = "Enables Ruby based applications to communicate with the Xero API"
  s.has_rdoc    = false
  s.authors     = ["Tim Connor", "Nik Wakelin", "Jared Armstrong"]
  s.license     = "MIT"

  s.files       = ["Gemfile", "LICENSE", "Rakefile", "README.md", "xero_gateway.gemspec"] + Dir['**/*.rb'] + Dir['**/*.crt']

  s.add_dependency "builder", ">= 3.2.2"
  s.add_dependency "oauth", ">= 0.3.6"
  s.add_dependency "activesupport"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "libxml-ruby", "2.7.0"

end
