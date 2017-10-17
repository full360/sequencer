Gem::Specification.new do |s|
  s.name        = 'full360-sequencer'
  s.version     = '0.0.6'
  s.date        = '2017-10-17'
  s.summary     = "full360 sequencer utility"
  s.description = "automation for simple batch jobs run in AWS"
  s.authors     = ["pankaj batra","jeremy winters"]
  s.email       = 'pankaj.batra@full360.com'
  s.files       = ["lib/full360-sequencer.rb"]
  s.executables = ["sequencer"]
  s.homepage    = 'https://www.full360.com'
  s.license     = 'MIT'
  
  s.add_runtime_dependency 'logger','~>1.2'
  s.add_runtime_dependency 'aws-sdk','~>2.9'
  
  s.add_development_dependency 'minitest','~>5.9'

  s.required_ruby_version = '>= 2.0' 
end