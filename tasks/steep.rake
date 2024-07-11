# frozen_string_literal: true

# @type self: Rake::TaskLib

if Gem.loaded_specs["steep"]
  require "steep"
else
  warn "'steep' gem not loaded: skipping tasks..." if Rake.verbose == true
  return
end

namespace :steep do
  desc "Run static type checking"
  task :check do |_task, args|
    args_sh = args.to_a.map { |a| "'#{a}'" }.join(" ")

    sh "steep check #{args_sh}".strip
  end

  desc "Output static type checking statistics"
  task :stats do |_task, args|
    format = args.to_a.first || "table"

    if format == "md"
      data = `steep stats --format=csv`

      require "csv"

      csv = CSV.new(data, headers: true)
      headers = true
      csv.each do |row|
        hrow = row.to_h

        if headers
          $stdout.write("|")
          $stdout.write(hrow.keys.join("|"))
          $stdout.write("|")
          $stdout.write("\n")

          $stdout.write("|")
          $stdout.write(hrow.values.map { |v| /^\d+$/.match?(v) ? "--:" : ":--" }.join("|"))
          $stdout.write("|")
          $stdout.write("\n")
        end

        headers = false

        $stdout.write("|")
        $stdout.write(hrow.values.join("|"))
        $stdout.write("|")
        $stdout.write("\n")
      end
    else
      sh "steep stats --format=#{format}"
    end
  end
end

desc "Run type checks"
task check: :"steep:check"
