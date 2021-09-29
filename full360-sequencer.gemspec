lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "full360_sequencer/version"

Gem::Specification.new do |spec|
  spec.name        = "full360-sequencer"
  spec.version     = Full360::Sequencer::VERSION
  spec.date        = "2017-10-17"
  spec.summary     = "Full 360 sequencer utility"
  spec.description = "Automation for simple batch jobs run in AWS"
  spec.authors     = ["Full 360 Group"]
  spec.email       = "support@full360.com"
  spec.files       = ["lib/full360-sequencer.rb"]
  spec.homepage    = "https://full360.com"
  spec.license     = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Make it Ruby 2+ only
  spec.required_ruby_version = ">= 2.0"

  spec.add_runtime_dependency "logger", "~> 1.2"
  spec.add_runtime_dependency "aws-sdk", "~> 2.9"

  # development dependencies
  spec.add_development_dependency "minitest", "~> 5.9"
  spec.add_development_dependency "rake", "~> 12"
end
