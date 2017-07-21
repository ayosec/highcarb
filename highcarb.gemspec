# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "highcarb/version"

Gem::Specification.new do |s|
  # Metadata
  s.name        = "highcarb"
  s.version     = HighCarb::Version
  s.authors     = ["Ayose Cazorla"]
  s.email       = ["ayosec@gmail.com"]
  s.homepage    = "https://github.com/ayosec/highcarb"
  s.summary     = %q{Slides manager based on Deck.js }
  s.description = %q{HighCarb can build a presentation based on HAML, Markdown or raw HTML}

  # Manifest
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "thin"
  s.add_runtime_dependency "mime-types"
  s.add_runtime_dependency "trollop"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "sass"
  s.add_runtime_dependency "kramdown"
  s.add_runtime_dependency "rouge"
end

