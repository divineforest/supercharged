$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "supercharged/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "supercharged"
  s.version     = Supercharged::VERSION
  s.authors     = ["divineforest"]
  # s.email       = ["TODO: Your email"]
  # s.homepage    = "TODO"
  s.summary     = "MVC solution for charges in rails"
  # s.description = "TODO: Description of Supercharged."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.1"
  s.add_dependency "state_machine"
  s.add_dependency "state_machine-audit_trail"
  s.add_dependency "activemerchant"
  s.add_dependency 'strong_parameters'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest", "~> 3.0"
  s.add_development_dependency "minitest-spec-context"
end
