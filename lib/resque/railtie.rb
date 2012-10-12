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
    config.resque = ActiveSupport::OrderedOptions.new.tap do |resque|
      resque.queue = :rails
      resque.inline = false

      resque.redis_config_path = 'config/resque-redis.yml'
      resque.redis_config = nil
      resque.redis = nil
    end

    rake_tasks do
      require 'resque/tasks'
    end

    initializer 'resque.configure' do
      config.resque.env   ||= Rails.env
      config.resque.queue ||= "#{app.railtie_name}_#{config.resque.env}"

      if config.resque.inline.nil? && config.resque.redis.nil?
        require 'psych'
        config.resque.redis_config_path ||= 'config/resque-redis.yml'
        config.resque.redis_config ||= Psych.load(config.root.join(config.resque.redis_config_path))[config.resque.env].try(:symbolize_keys)

        if config.nil? || config[:inline]
          config.resque.inline = true
        else
          require 'redis'
          config.resque.redis = Redis.new(config)
        end
      end

      Rails.queue[:default] =
        if config.resque.inline
          ActiveSupport::SynchronousQueue.new
        else
          require 'resque/rails/queue'
          Resque::Rails::Queue.new(config.resque.queue)
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
  end
end
