require 'json'

manifest_file = File.read(File.expand_path('../../app.json', __FILE__))
app = JSON.parse(manifest_file)

commit = ARGV[0]
version = "#{app['version']}.pre.#{commit[0..7]}"
package_name = app['name']

# Update back manifest file
app['version'] = version
File.open(manifest_file_path, "w") do |f|
  f.write(JSON.pretty_generate(app))
end

gemspec_file_name = Dir.glob('./*.gemspec')[0].split('/')[-1]

exec("gem build #{gemspec_file_name} && curl -F package=@#{package_name}-#{version}.gem https://#{ENV['GEMFURY_TOKEN']}@push.fury.io/#{ENV['GEMFURY_PACKAGE']}/")
