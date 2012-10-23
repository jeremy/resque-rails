require 'resque'

module Resque
  module Rails
    class Queue
      attr_reader :default_queue_name

      def initialize(default_queue_name)
        @default_queue_name = default_queue_name
      end

      def push(job)
        queue = job.respond_to?(:queue_name) ? job.queue_name : default_queue_name
        Resque.enqueue_to queue, MarshaledJob, Marshal.dump(job)
      end
    end

    class MarshaledJob
      def self.perform(marshaled_job)
        Marshal.load(marshaled_job).run
      end
    end
  end
end
