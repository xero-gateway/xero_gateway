require 'json'

manifest_file = File.read(File.expand_path('../../app.json', __FILE__))
app = JSON.parse(manifest_file)
version = app['version']
package_name = app['name']

gemspec_file_name = Dir.glob('./*.gemspec')[0].split('/')[-1]

abort('Development Gem must have .dev in version') unless version.include?('dev')

exec("gem build #{gemspec_file_name} && curl -F package=@#{package_name}-#{version}.gem https://#{ENV['GEMFURY_TOKEN']}@push.fury.io/#{ENV['GEMFURY_PACKAGE']}/")
