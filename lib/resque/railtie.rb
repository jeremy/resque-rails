require 'rails/railtie'

module Resque
  # App config:
  #
  #   config.resque.env = 'beta'    # Defaults to Rails.env
  #   config.resque.inline = false  # Defaults to false
  #
  #   config.resque.redis_config_path = 'config/resque-redis.yml'  # Relative to Rails.root
  #   config.resque.redis_config = { ... }    # Hash of config options
  #   config.resque.redis = Redis.new(...)    # Redis instance
  #
  # Example config/resque-redis.yml:
  #
  #   development:
  #     inline: true
  #   production:
  #     host: 10.0.0.1
  #     port: 6379
  #     timeout: 1
  #
  class Railtie < ::Rails::Railtie
    require 'resque/rails/configuration'
    config.resque = Resque::Rails::Configuration.new

    rake_tasks { require 'resque/tasks' }

    initializer 'resque' do |app|
      config.resque.setup app
    end

    initializer 'resque.before_fork.active_record' do |app|
      unless app.config.resque.inline
        require 'active_support/lazy_load_hooks'
        ActiveSupport.on_load :active_record do
          require 'resque'
          Resque.before_fork do |job|
            ActiveRecord::Base.clear_all_connections!
          end
        end
      end
    end
  end
end
