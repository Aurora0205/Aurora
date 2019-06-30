$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aurora/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aurora"
  s.version     = Aurora::VERSION
  s.authors     = ["Kashiwara"]
  s.email       = ["aurora0205k@gmail.com"]
  s.summary     = "This gem is seeder which is very usefull"
  s.description = "Please look posted information on github"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0"
  s.add_dependency 'activerecord-import', '>= 1.00'
  s.add_dependency 'tomlrb', '>= 1.00'
end