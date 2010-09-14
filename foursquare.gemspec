# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{foursquare}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeremy Welch", "Thomas Hanley", "Elise Wood"]
  # s.autorequire = %q{foursquare}
  s.date = %q{2010-03-13}
  s.description = %q{A simple Ruby wrapper for the Foursquare API}
  s.email = %q{hello@jeremyrwelch.com}
  s.extra_rdoc_files = ["README.rdoc", "History"]
  s.files = ["README.rdoc", "Rakefile", "History", "lib/foursquare.rb", "spec/foursquare_spec.rb", "spec/spec_helper.rb", "script/destroy", "script/generate"]
  s.homepage = %q{http://foursquare.rubyforge.org}
  s.post_install_message = %q{NOTE: This version of the Foursquare Gem has added OAuth support. Basic Auth has been deprecated. Also significant changes have bee made to the way methods are called. Please review the examples in the README.}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{See example: http://github.com/jeremyrwelch/Foursquare/blob/master/README.rdoc}

  dependencies = [
    ['httparty', '= 0.4.3'],
    ['hashie', '>= 0.1.8'],
    ['oauth', '>= 0.3.5'],
  ]

  dependencies.each do |dep|
    if s.respond_to? :specification_version then
      current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
      s.specification_version = 3

      if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
        s.add_runtime_dependency(dep.first, dep.last)
      else
        s.add_dependency(dep.first, dep.last)
      end
    else
      s.add_dependency(dep.first, dep.last)
    end
  end
end
