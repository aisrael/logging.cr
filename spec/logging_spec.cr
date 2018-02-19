require "./spec_helper"

class Foo
  include Logging

  def foo
    debug "Debug message"
  end
end

describe Logging do
  it "works" do
    Logging::Config.root_level = Logger::DEBUG
    s = String.build(1024) do |sb|
      Logging::Config.root_log_to = sb
      f = Foo.new
      f.foo
    end.chomp
    expected_pattern = %r(^D, \[\d{4,4}-\d{2,2}-\d{2,2} \d{2,2}:\d{2,2}:\d{2,2} \+\d{2,2}:\d{2,2} #\d+\] DEBUG -- : /spec/logging_spec.cr:7 Debug message)
    s.should match(expected_pattern)
  end
end
