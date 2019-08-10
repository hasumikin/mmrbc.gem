lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mrbcc/version"

Gem::Specification.new do |spec|
  spec.name          = "mrbcc"
  spec.version       = Mrbcc::VERSION
  spec.authors       = ["HASUMI Hitoshi"]
  spec.email         = ["hasumikin@gmail.com"]

  spec.summary       = %q{A minimun mruby compiler written in Ruby}
  spec.description   = %q{mruby/c VM as a target. Error detection and correction, supporting complete syntax and optimization are beyond the scope.}
  spec.homepage      = "https://github.com/hasumikin/mrbcc.gem"
  spec.license       = "MIT"

#  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
#  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit", "~> 3.3"

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "nokogiri"
end
