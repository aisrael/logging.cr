require "logger"
require "./logging/*"

module Logging
  {% for name in Logger::Severity.constants %}
    macro self.{{name.id.downcase}}(message)
      Logging::Config.get_logger(self.to_s).{{name.id.downcase}}(%(#{__FILE__[Dir.current.size..-1]}:#{__LINE__} ) + \{{message}})
    end
    macro {{name.id.downcase}}(message)
      Logging::Config.get_logger(self.class.to_s).{{name.id.downcase}}(%(#{__FILE__[Dir.current.size..-1]}:#{__LINE__} ) + \{{message}})
    end
  {% end %}
  class Config
    def self.root_level=(level : Logger::Severity)
      @@root_logger.level = level
    end
    def self.root_level : Logger::Severity
      @@root_logger.level
    end
    def self.root_log_to=(io : IO)
      old_level = @@root_logger.level
      @@root_logger = Logger.new(io)
      @@root_logger.level = old_level
    end
    def self.get_logger(name)
      parts = name.split("::")
      found = parts.size.downto(0).find do |i|
        key = parts[0..i].join("/")
        @@loggers.has_key?(key)
      end
      if found
        key = parts[0..found].join("/")
        @@loggers[key].not_nil!
      else
        @@root_logger
      end
    end
    @@root_logger : Logger = Logger.new(STDOUT).tap do |logger|
      logger.level = Logger::WARN
    end
    @@loggers : Hash(String, Logger) = Hash(String, Logger).new.tap do |h|
      h[""] = @@root_logger
    end
  end
end
