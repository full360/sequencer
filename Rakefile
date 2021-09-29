require "bundler/gem_tasks"

task :test do
  Dir["./test/*_test.rb"].each { |file| require file}
end

task default: %w(test)
