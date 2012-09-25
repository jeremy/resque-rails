Gem::Specification.new do |s|
  s.name      = 'resque-rails'
  s.version   = '1.0.0'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremy@bitsweat.net'
  s.homepage  = 'https://github.com/jeremy/resque-rails'
  s.summary   = 'Rails.queue support for Resque'

  s.add_dependency 'resque'
  s.add_dependency 'rails'
  s.add_development_dependency 'minitest'

  s.files = Dir["#{File.dirname(__FILE__)}/**/*"]
end
