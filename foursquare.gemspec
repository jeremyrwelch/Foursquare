# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{foursquare}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Welch"]
  s.autorequire = %q{foursquare}
  s.date = %q{2009-11-08}
  s.description = %q{A simple Ruby wrapper for the Foursquare API}
  s.email = %q{hello@jeremyrwelch.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "History"]
  s.files = ["LICENSE", "README.rdoc", "Rakefile", "History", "lib/foursquare.rb", "spec/foursquare_spec.rb", "spec/spec_helper.rb", "script/destroy", "script/generate"]
  s.homepage = %q{http://foursquare.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple Ruby wrapper for the Foursquare API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, ["= 0.4.3"])
    else
      s.add_dependency(%q<httparty>, ["= 0.4.3"])
    end
  else
    s.add_dependency(%q<httparty>, ["= 0.4.3"])
  end
end
