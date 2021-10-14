require "logger"
require "aws-sdk-s3"

# Autoload all gem classes
module Full360
  module Sequencer
    autoload :VERSION,     "full360_sequencer/version"
    autoload :Runner,      "full360_sequencer/runner"
    autoload :RunECSTask,  "full360_sequencer/run_ecs_task"
    autoload :RunTaskBase, "full360_sequencer/run_task_base"
  end
end
