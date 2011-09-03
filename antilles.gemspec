$:.push File.expand_path("../lib", __FILE__)
require "antilles/version"

Gem::Specification.new do |s|
  s.name        = "antilles"
  s.version     = AntillesVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Solano Labs"]
  s.email       = ["info@tddium.com"]
  s.homepage    = "http://www.tddium.com/"
  s.summary     = %q{Easy API Mimicing for Cucumber}
  s.description = <<-EOF
Antilles uses Mimic to set up a stub HTTP server that a CLI tool being tested
with cucumber/aruba can communicate with.
EOF

  s.rubyforge_project = "tddium"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency("json")
  s.add_runtime_dependency("bundler")
  s.add_runtime_dependency("mimic")
  s.add_runtime_dependency("httparty")
  s.add_runtime_dependency("daemons")

  s.add_development_dependency("rspec")
  s.add_development_dependency("rake")
end
