#!/usr/bin/env ruby

require "psych"
require "open3"

ruby_versions = [2.5, 2.6, 2.7, 3.0, 3.1, 3.2, 3.3]

services = ruby_versions.reduce({}) do |hash, version|
  hash.merge(
    "ruby-#{version}" => {
      "build" => {
        "context" => ".",
        "dockerfile" => "images/ruby-#{version}.dockerfile"
      },
      "command" => "/bin/bash",
      "environment" => {
        "BUNDLE_GEMFILE" => "gemfiles/ruby-#{version}.gemfile"
      },
      "stdin_open" => true,
      "tty" => true,
      "volumes" => [
        ".:/app",
        "bundle-#{version}:/usr/local/bundle"
      ]
    }
  )
end

volumes = ruby_versions.reduce({}) do |hash, version|
  hash.merge("bundle-#{version}" => nil)
end

docker_compose = {
  "version" => "3.2",
  "services" => services,
  "volumes" => volumes
}

target = "docker-compose.yml"

File.open(target, "w") do |f|
  f.write("# Please do NOT manually edit this file.\n")
  f.write("# This file is generated by '#{__FILE__}'\n")
  f.write(Psych.dump(docker_compose))
end

git_diff, _ = Open3.capture2("git diff --color #{target}")

if git_diff.empty?
  puts "No changes. '#{target}' is up-to-date."
else
  puts "'#{target}' has been updated. Please review the changes below:\n\n"
  puts git_diff
end
