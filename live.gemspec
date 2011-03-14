# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "live/version"

Gem::Specification.new do |s|
  s.name        = "live"
  s.version     = Live::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Macario Ortega"]
  s.email       = ["macarui@gmail.com"]
  s.homepage    = "http://github.com/maca/live"
  s.summary     = %q{Live is like IRC only it is meant to be used from a text editor}
  s.description = %q{Live is like IRC only it is meant to be used from a text editor, it essentially polls a *nix pipe and evaluates its contents. 
It was devised for audiovisual livecoding (ruby-processing and scruby), a block can be bound to a key and can be called later by a keystroke.}

  s.post_install_message = File.read("#{File.dirname(__FILE__)}/README.rdoc")
  
  s.add_dependency 'highline'

  s.rubyforge_project = "live"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
