require 'test_helper'
require 'active_support/testing/isolation'

class RailtieTest < MiniTest::Unit::TestCase
  include ActiveSupport::Testing::Isolation

  ROOT = File.expand_path('../app', __FILE__)

  def setup
    FileUtils.mkdir_p "#{ROOT}/config"
    File.write("#{ROOT}/config/resque-redis.yml", Psych.dump('development' => { 'host' => 'localhost' }))
    Dir.chdir ROOT

    require 'rails'
    require 'resque/railtie'
    @app = Class.new(::Rails::Application).tap do |app|
      app.config.root = ::RailtieTest::ROOT
      app.config.eager_load = false
      app.initializer('rack app') { |app| app.instance_variable_set '@app', -> env { [200, {}, []] }}
    end
  end

  def test_default_config
    @app.initialize!

    assert_equal Rails.env, @app.config.resque.env
    assert_equal :"#{@app.railtie_name}_#{@app.config.resque.env}", @app.config.resque.queue

    assert_equal false, @app.config.resque.inline

    assert_equal @app.config.root.join('config/resque-redis.yml'), @app.config.resque.redis_config_path
    assert_equal({ host: 'localhost' }, @app.config.resque.redis_config)
    assert_kind_of Redis, @app.config.resque.redis

    assert_kind_of Resque::Rails::Queue, @app.queue
  end

  def test_custom_redis_config_path
    File.write("#{ROOT}/foo.yml", Psych.dump('development' => { 'host' => 'foo' }))
    @app.configure { config.resque.redis_config_path = "#{ROOT}/foo.yml" }
    @app.initialize!

    assert_equal({ host: 'foo' }, @app.config.resque.redis_config)
    assert_kind_of Redis, @app.config.resque.redis
    assert_kind_of Resque::Rails::Queue, @app.queue
  end

  def test_inline
    @app.configure { config.resque.inline = true }
    @app.initialize!

    assert_equal true, @app.config.resque.inline
    assert !@app.queue.kind_of?(Resque::Rails::Queue)
    assert_nil @app.config.resque.redis
  end

  def test_missing_config_treated_as_inline
    @app.config.resque.redis_config = {}
    @app.initialize!

    assert_equal true, @app.config.resque.inline
    assert !@app.queue.kind_of?(Resque::Rails::Queue)
    assert_nil @app.config.resque.redis
  end
end
