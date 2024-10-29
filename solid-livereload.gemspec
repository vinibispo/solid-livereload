require_relative "lib/solid/livereload/version"

Gem::Specification.new do |spec|
  spec.name = "solid-livereload"
  spec.version = Solid::Livereload::VERSION
  spec.authors = ["Kirill Platonov"]
  spec.email = ["mail@kirillplatonov.com"]
  spec.homepage = "https://github.com/vinibispo/solid-livereload"
  spec.summary = "Automatically reload Hotwire Turbo when app files are modified."
  spec.license = "MIT"

  spec.files = Dir["{app,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "railties", ">= 6.0.0"
  spec.add_dependency "actioncable", ">= 6.0.0"
  spec.add_dependency "listen", ">= 3.0.0"
end
