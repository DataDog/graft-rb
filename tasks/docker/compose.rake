# frozen_string_literal: true

# @type self: Rake::DSL

namespace :docker do
  namespace :compose do
    desc "Generate docker-compose.yml"
    task :generate do |_task, args|
      check = args.to_a.include?("check")

      require "psych"
      require "open3"

      # TODO: Extract the matrix to another file to be reused
      images = [
        "jruby:9.2",
        "jruby:9.3",
        "jruby:9.4",
        "ruby:2.5",
        "ruby:2.6",
        "ruby:2.7",
        "ruby:3.0",
        "ruby:3.1",
        "ruby:3.2",
        "ruby:3.3",
        "ruby:3.4"
      ]

      docker_compose = images.each_with_object({"services" => {}, "volumes" => {}}) do |image, compose|
        ruby = image.sub(":", "-")

        compose["services"][ruby] = {
          "build" => {
            "context" => ".",
            "dockerfile" => "ghcr.io/datadog/images-rb/engines/#{image}"
          },
          "command" => "/bin/bash",
          "environment" => {
            "BUNDLE_GEMFILE" => "gemfiles/#{ruby}.gemfile"
          },
          "stdin_open" => true,
          "tty" => true,
          "volumes" => [
            ".:/app",
            "bundle-#{ruby}:/usr/local/bundle"
          ],
          "working_dir" => "/app"
        }

        compose["volumes"]["bundle-#{ruby}"] = nil
      end

      target = "docker-compose.yml"

      original = File.binread(target)

      new = +""
      new << <<~EOS
        # Please do NOT manually edit this file.
        # This file is generated by 'bundle exec rake docker:compose:generate'
      EOS
      new << Psych.dump(docker_compose)

      if original == new
        puts "No changes. '#{target}' is up-to-date."
      elsif check
        puts "'#{target}' has changed. Please review the changes and commit."

        require "tmpdir"

        Dir.mktmpdir do |d|
          Dir.chdir(d) do
            File.binwrite(target + ".orig", original)
            File.binwrite(target, new)
            sh "diff -u #{target}.orig #{target}"
            sh "diff -u #{target}.orig #{target} | od -xa"
          end
        end

        exit 1
      else
        File.binwrite(target, new)
        puts "'#{target}' has been updated. Please review the changes below:\n\n"
        sh "git diff --color #{target}"
      end
    end
  end
end
