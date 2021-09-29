require "minitest/autorun"

# using a global variable because this is only a test
$base_path = File.expand_path("#{File.dirname(__FILE__)}/../")

require_relative "#{$base_path}/lib/full360-sequencer.rb"

class TestSequencerRunner < Minitest::Test
  def create_runner
    Full360::Sequencer::Runner.new
  end

  def valid_yml_as_object
    [{"chicken_butter"=>
     {"type"=>"ecs_task",
      "ignore_failure"=>false,
      "active"=>true,
      "parameters"=>
       {"cluster"=>"yourcluster",
        "task_definition"=>"test-task-def:1",
        "count"=>1}}},
   {"turkey_fingers"=>
     {"type"=>"ecs_task",
      "ignore_failure"=>false,
      "active"=>true,
      "parameters"=>
       {"cluster"=>"yourcluster2",
        "task_definition"=>"test-task-def:2",
        "count"=>1}}}]
  end

  def test_run_task_class
    f = create_runner

    assert_equal(
      Full360::Sequencer::RunECSTask,
      f.run_task_class("ecs_task")
    )

    assert_nil(
      nil,
      f.run_task_class("bad_info")
    )
  end

  def test_task_name
    f = create_runner

    assert_equal(
      "chicken",
      f.task_name({"chicken" => 2, "turkey" => 3})
    )
  end

  def test_parse_config_file
    f = create_runner

    assert_equal(
      valid_yml_as_object,
      f.parse_config_file("#{$base_path}/test/fixtures/valid.yml")
    )
  end

  def test_config_valid?
    f = create_runner

    assert_equal(
      true,
      f.config_valid?([1, 2, 3])
    )

    assert_equal(
      false,
      f.config_valid?({a: 1})
    )
  end

  def test_config_from_file
    f = create_runner
    f.config_from_file("#{$base_path}/test/fixtures/valid.yml")
    assert_equal(
      valid_yml_as_object,
      f.config
    )
  end
end

class TestRunECSTask < Minitest::Test
  def test_keys_to_symbol
    t = Full360::Sequencer::RunECSTask.new(
      "test-task",
      {"parameters" => {}}
    )

    assert_equal(
      {a: 1, b: 2},
      t.keys_to_symbol(
        {"a" => 1, "b" => 2}
      )
    )
  end
end
