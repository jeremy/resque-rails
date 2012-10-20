module Resque
  module Rails
    class Configuration
      attr_writer :env, :inline, :redis_config
      attr_accessor :queue, :redis, :redis_config_path

      def initialize
        @env = @inline = @redis_config = nil
        @queue = @redis = @redis_config_path = nil
      end

      def setup(app)
        require 'resque/rails/queue'

        @queue ||= :"#{app.railtie_name}_#{env}"
        @redis_config_path ||= app.config.root.join('config/resque-redis.yml')

        if inline
          Resque.inline = true
        else
          Resque.redis = build_redis
        end

        app.queue = Resque::Rails::Queue.new(queue)
      end

      def env
        @env ||= defined?(::Rails.env) ? ::Rails.env : 'development'
      end

      def inline
        @inline ||= @redis.nil? && redis_config.blank?
      end

      def build_redis
        @redis ||=
          if redis_config.present?
            require 'redis'
            Redis.new redis_config
          end
      end

      def redis_config
        @redis_config ||= load_redis_config[env].try(:symbolize_keys)
      end

      def load_redis_config
        if @redis_config_path
          require 'psych'
          Psych.load_file @redis_config_path
        else
          {}
        end
      end
    end
  end
end
