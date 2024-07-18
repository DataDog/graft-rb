# frozen_string_literal: true

# Ensure we are using a compatible version of SimpleCov
major, minor, patch = SimpleCov::VERSION.scan(/\d+/).first(3).map(&:to_i)
if major < 0 || minor < 9 || patch < 0
  raise "The version of SimpleCov you are using is too old. " \
        "Please update with `gem install simplecov` or `bundle update simplecov`"
end

require "simplecov-html"

module SimpleCov
  module Formatter
    class MarkdownFormatter < HTMLFormatter
      def initialize
        @branchable_result = SimpleCov.branch_coverage?
        @templates = {}
      end

      def format(result)
        File.open(File.join(output_path, "coverage.md"), "wb") do |file|
          file.puts template("layout").result(binding)
        end

        # TODO: disabled til `views/source_file.md.erb` is implemented
        # result.source_files.each do |source_file|
        #   path = File.dirname(File.join(output_path, shortened_filename(source_file)))
        #
        #   FileUtils.mkdir_p(path)
        #
        #   File.open(File.join(output_path, shortened_filename(source_file)) + ".md", "wb") do |file|
        #     file.puts formatted_source_file(source_file)
        #   end
        # end

        puts output_message(result)
      end

      def output_message(result)
        str = "Markdown coverage report generated for #{result.command_name} to #{output_path}. #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
        str += " #{result.covered_branches} / #{result.total_branches} branches (#{result.coverage_statistics[:branch].percent.round(2)}%) covered." if branchable_result?
        str
      end

      private

      # Returns the an erb instance for the template of given name
      def template(name)
        @templates[name] ||= ERB.new(File.read(File.join(File.dirname(__FILE__), "./views/", "#{name}.md.erb")))
      end

      def link_to_source_file(source_file)
        shortened_filename source_file
      end
    end
  end
end
