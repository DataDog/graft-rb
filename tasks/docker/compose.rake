# frozen_string_literal: true

# @type self: Rake::DSL

namespace :docker do
  namespace :compose do
    desc "Generate docker-compose.yml"
    task :generate do |_task, args|
      check = args.to_a.include?("check")

      require "psych"
      require "open3"

      images = Dir.glob(File.join("images", "**", "*.dockerfile"))

      docker_compose = images.each_with_object({"services" => {}, "volumes" => {}}) do |image, compose|
        ruby = File.basename(image, ".dockerfile")
        version = ruby =~ /(\d+\.\d+)$/ && $1

        compose["services"][ruby] = {
          "build" => {
            "context" => ".",
            "dockerfile" => image
          },
          "command" => "/bin/bash",
          "environment" => {
            "BUNDLE_GEMFILE" => "gemfiles/#{ruby}.gemfile"
          },
          "stdin_open" => true,
          "tty" => true,
          "volumes" => [
            ".:/app",
            "bundle-#{version}:/usr/local/bundle"
          ]
        }

        compose["volumes"]["bundle-#{version}"] = nil
      end

      target = "docker-compose.yml"

      File.open(target, "w") do |f|
        f.write("# Please do NOT manually edit this file.\n")
        f.write("# This file is generated by 'bundle exec rake docker:compose:generate'\n")
        f.write(Psych.dump(docker_compose))
      end

      git_diff, _ = Open3.capture2("git diff --color #{target}")

      if git_diff.empty?
        puts "No changes. '#{target}' is up-to-date."
      else
        puts "'#{target}' has been updated. Please review the changes below:\n\n"
        puts git_diff

        exit 1 if check
      end
    end
  end
end
