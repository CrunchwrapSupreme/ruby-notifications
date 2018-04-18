
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby-notifications/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby-notifications"
  spec.version       = Notifications::VERSION
  spec.authors       = ["David Young"]
  spec.email         = ["david@davidyoung.space"]

  spec.summary       = "Simple interface for the org.freedesktop.Notifications service."
  spec.homepage      = "https://github.com/CrunchwrapSupreme/ruby-notifications.git"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency "ruby-dbus", "~> 0.14.1"
end
