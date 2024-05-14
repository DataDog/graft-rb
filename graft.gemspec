# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "graft"
  s.version = "0.3.0"
  s.licenses = ["BSD-3-Clause"]
  s.summary = "Standardised hook interface"
  s.description = "Vendor-independent collaborative hooking library for Ruby"
  s.authors = ["Loic Nageleisen"]
  s.email = "loic.nageleisen@gmail.com"
  s.files = Dir.glob("lib/**/*.rb")
  s.homepage = "https://rubygems.org/gems/graft"
  s.metadata = {
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/DataDog/graft-rb"
  }

  s.required_ruby_version = ">= 2.5"
end
