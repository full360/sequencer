module Full360
  module Sequencer
    class RunTaskBase
      attr_reader :success
      attr_reader :exit_code

      def run_task; end
      def completed?; end
      def kill_task; end # will be used for timeout
    end
  end
end
