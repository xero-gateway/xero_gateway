require 'json'

manifest_file = File.read(File.expand_path('../../app.json', __FILE__))
app = JSON.parse(manifest_file)
version = app['version']
package_name = app['name']

gemspec_file_name = Dir.glob('./*.gemspec')[0].split('/')[-1]

abort('Pre-release Gem must have .alpha in version') unless version.include?('alpha')

exec("gem build #{gemspec_file_name} && curl -F package=@#{package_name}-#{version}.gem https://#{ENV['GEMFURY_TOKEN']}@push.fury.io/#{ENV['GEMFURY_PACKAGE']}/")
