$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "irxrb-rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "irxrb-rails"
  s.version     = Irxrb::Rails::VERSION::STRING
  s.authors     = ["irxground"]
  s.email       = ["irxnjhtchlnrw@gmail.com"]
#  s.homepage    = "TODO"
  s.summary     = "Rails extension"
  s.description = "Rails extension"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "sqlite3"
end
