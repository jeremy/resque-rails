module Resque
  module Rails
    class Queue
      attr_reader :queue

      def initialize(options)
        require 'resque'
        @queue = Resque::Queue.new \
          options.fetch(:queue, :rails),
          options.fetch(:redis),
          Marshal
      end

      def push(job)
        Resque::Job.create @queue, Job, job
      end

      def pop(*args)
        @queue.pop *args
      end
    end

    class Job
      def self.perform(job)
        job.run
      end

      def initialize(job)
        @job = job
      end

      def run
        @job.run
      end
    end
  end
end
