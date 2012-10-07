Gem::Specification.new do |s|
  s.name      = 'resque-rails'
  s.version   = '1.0.0'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremy@bitsweat.net'
  s.homepage  = 'https://github.com/jeremy/resque-rails'
  s.summary   = 'Rails.queue support for Resque'

  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'resque' #,  '~> 2.0'  # master branch is still 1.22
  s.add_dependency 'rails',   '~> 4.0.0.beta'
  s.add_development_dependency 'minitest'

  s.files = Dir["#{File.dirname(__FILE__)}/**/*"]
end
