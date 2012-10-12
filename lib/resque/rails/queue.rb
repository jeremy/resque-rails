require 'resque'

module Resque
  module Rails
    class Queue
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def push(job)
        Resque.enqueue_to @name, MarshaledJob, Marshal.dump(job)
      end
    end

    class MarshaledJob
      def self.perform(marshaled_job)
        Marshal.load(marshaled_job).run
      end
    end
  end
end
