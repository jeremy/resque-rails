require 'test_helper'
require 'resque/rails/queue'
require 'redis'

class QueueTest < MiniTest::Unit::TestCase
  class TestJob
    attr_accessor :pushed
  end

  def setup
    @redis = Redis.new
    @queue = Resque::Rails::Queue.new(redis: @redis)
  end

  def test_wraps_a_resque_queue
    assert_equal :rails, @queue.queue.name
  end

  def test_pushes_job_wrapper
    def @queue.<<(job)
      job.pushed = true
    end

    job = TestJob.new
    @queue.push job

    assert job.pushed
  end

  def test_pop_delegates
    assert_nil @queue.pop(:non_block)
  end
end
