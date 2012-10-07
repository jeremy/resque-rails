require 'rails/railtie'
require 'active_support/ordered_options'

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
  class Railtie < Rails::Railtie
    config.resque = ActiveSupport::OrderedOptions.new

    config.resque.redis = nil
    config.resque.redis_config = nil
    config.resque.redis_config_path = 'config/resque-redis.yml'
    config.resque.inline = false

    rake_tasks do
      require 'resque/tasks'
    end

    initializer 'resque.configure' do
      if config.resque.inline.nil? && config.resque.redis.nil?
        config = redis_env_config
        if config.nil? || config[:inline]
          config.resque.inline = true
        else
          config.resque.redis = connect_to_redis(config)
        end
      end
    end

    initializer 'resque.set_rails_default_queue', after: 'resque.configure' do
      Rails.queue[:default] =
        if config.resque.inline
          ActiveSupport::SynchronousQueue.new
        else
          require 'resque/rails/queue'
          Resque::Rails::Queue.new(config.resque.redis)
        end
    end

    initializer 'resque.before_fork.active_record' do
      require 'active_support/lazy_load_hooks'

      ActiveSupport.on_load :active_record do
        require 'resque'
        Resque.before_fork do |job|
          ActiveRecord::Base.clear_all_connections!
        end
      end
    end

    def connect_to_redis(config)
      require 'redis'
      Redis.new(config).tap do |redis|
        redis.ping
        redis.client.disconnect
      end
    end

    def resque_env
      config.resque.env ||= Rails.env
    end

    def redis_env_config
      redis_config[resque_env].try(:symbolize_keys)
    end

    def redis_config
      require 'psych'
      config.resque.redis_config || Psych.load(redis_config_path)
    end

    def redis_config_path
      config.root.join(config.resque.redis_config_path || 'config/resque-redis.yml')
    end
  end
end
