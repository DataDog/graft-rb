# frozen_string_literal: true

module Minitest
  module Reporters
    # A reporter that emits one line per test, for VSCode
    class VSCodeReporter < DefaultReporter
      def report
        require "json"

        $stdout.write "\n"
        tests.each_with_index do |test, index|
          index += 1
          name = [test.klass, test.name].join("#").gsub(/#test_\d+_anonymous$/, "")

          if test.passed?
            status = "PASS"
            severity = ""
          elsif test.skipped?
            status = "SKIP"

            message = test.failure.to_s
            severity = "info"
          elsif test.failure
            status = test.failure.is_a?(Minitest::UnexpectedError) ? "ERROR" : "FAIL"
            severity = "error"

            message = if test.failure.is_a?(Minitest::UnexpectedError)
              "#{test.failure.error.class}: #{test.failure.error.message}"
            else
              test.failure.message.each_line.to_a.map(&:lstrip).map(&:chomp).join(" ")
            end
          end

          row = {
            index: index,
            status: status,
            name: name,
            time: test.time,
            assertions: test.assertions,
            source_location: test.source_location[0, 2].join(":")
          }

          row[:location] = test.failure.location if test.failure

          row[:severity] = severity unless severity.nil?
          row[:message] = message unless message.nil?

          # rendering
          $stdout.write printf("%<index> 5d %<status> 5s %<severity> 5s %<name>s", row)
          $stdout.write printf(" - %<location>s", row) if row.key?(:location)
          $stdout.write printf("\n")
          if row.key?(:message)
            row[:message].each_line { |l| $stdout.write printf("                  # %s\n", l.chomp) }
          end
        end
      end
    end
  end
end
