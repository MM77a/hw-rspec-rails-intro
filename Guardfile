guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(models|controllers)/(.+)\.rb$}) { |match| "spec/#{match[1]}/#{match[2]}_spec.rb" }
  watch(%r{^app/views/}) { 'spec/requests' }
  watch('config/routes.rb') { 'spec' }
  watch(%r{^spec/(rails|spec)_helper\.rb$}) { 'spec' }
end
