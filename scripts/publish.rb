require 'json'

manifest_file = File.read(File.expand_path('../../app.json', __FILE__))
app = JSON.parse(manifest_file)
gemspec_file_name = Dir.glob("./*.gemspec")[0].split('/')[-1]

exec("gem build #{gemspec_file_name} && curl -F package=@#{app['name']}-#{app['version']}.gem https://#{ENV['GEMFURY_TOKEN']}@push.fury.io/#{ENV['GEMFURY_PACKAGE']}/")