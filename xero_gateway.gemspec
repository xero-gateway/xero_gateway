Gem::Specification.new do |s|
  s.name     = "xero_gateway"
  s.version  = "2.0.12"
  s.date     = "2011-05-25"
  s.summary  = "Enables ruby based applications to communicate with the Xero API"
  s.email    = "tim@connorsoftware.com"
  s.homepage = "http://github.com/tlconnor/xero_gateway"
  s.description = "Enables ruby based applications to communicate with the Xero API"
  s.has_rdoc = false
  s.authors  = ["Tim Connor", "Nik Wakelin"]
  s.files = ["Gemfile", "LICENSE", "Rakefile", "README.textile", "xero_gateway.gemspec"] + Dir['**/*.rb'] + Dir['**/*.crt']
  s.add_dependency('builder', '>= 2.1.2')
  s.add_dependency('oauth', '>= 0.3.6')
  s.add_dependency('activesupport')
end
