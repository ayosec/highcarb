require_relative "lib/highcarb/version"

Gem::Specification.new do |s|
  # Metadata
  s.name        = "highcarb"
  s.version     = HighCarb::Version
  s.authors     = ["ayosec"]
  s.email       = ["ayosec@gmail.com"]
  s.homepage    = "https://github.com/ayosec/highcarb"
  s.summary     = %q{Slides manager}
  s.description = %q{HighCarb can build a presentation based on HAML, Markdown or raw HTML}

  # Manifest
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "kramdown"
  s.add_runtime_dependency "mime-types"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "rouge"
  s.add_runtime_dependency "sassc"
  s.add_runtime_dependency "thin"
  s.add_runtime_dependency "trollop"
end

