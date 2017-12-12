# coding: utf-8
require 'json'
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

app_path = File.expand_path('../app.json', __FILE__)
app = JSON.parse(File.read(app_path))

Gem::Specification.new do |s|
  s.name     = app['name']
  s.version  = app['version']
  s.date     = "2014-06-23"
  s.summary  = "Enables ruby based applications to communicate with the Xero API"
  s.email    = "dave@thinkei.com"
  s.homepage = "http://github.com/Thinkei/xero_gateway"
  s.description = "Includes the ability to update Xero payroll data"
  s.has_rdoc = false
  s.authors  = ["Tim Connor", "Nik Wakelin", "ThinkEI"]
  s.files = ["Gemfile", "LICENSE", "Rakefile", "README.textile", "xero_gateway.gemspec"] + Dir['**/*.rb'] + Dir['**/*.crt']
  s.add_dependency('oauth', '~> 0.4.0')
  s.add_dependency('activesupport')
  s.add_dependency('activemodel')
  s.add_dependency('retriable')
end
