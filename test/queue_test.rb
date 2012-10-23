require 'test_helper'
require 'resque/rails/queue'

$pushed = []
def Resque.push(queue, payload)
  $pushed << [queue, payload]
end

class QueueTest < MiniTest::Unit::TestCase
  class TestJob
  end

  class NamedQueueJob
    attr_reader :queue_name
    def initialize(queue_name)
      @queue_name = queue_name
    end
  end

  def setup
    @queue = Resque::Rails::Queue.new(:rails)
  end

  def teardown
    $pushed.clear
  end

  def test_pushes_marshaled_job_wrapper
    job = TestJob.new
    @queue.push job
    assert_pushed :rails, 'class' => 'Resque::Rails::MarshaledJob', 'args' => [Marshal.dump(job)]
  end

  def test_job_may_override_queue_name
    job = NamedQueueJob.new(:foo)
    @queue.push job
    assert_pushed :foo, 'class' => 'Resque::Rails::MarshaledJob', 'args' => [Marshal.dump(job)]
  end

  private
    def assert_pushed(queue, payload)
      assert_equal [queue, payload], $pushed.last
    end
end
