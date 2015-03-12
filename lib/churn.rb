require 'oj'
require 'set'

class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute opt = {}
    set_default_options
    check_exceptions opt
  end

  def self.check_exceptions opt = {}
    cwd = Dir.getwd
    begin
      raise StandardError, "#{COMMAND_NAME}: Not root directory specified" unless !root_directory.nil?
      raise StandardError, "#{COMMAND_NAME}: #{root_directory}: Not a directory" unless File.directory?(root_directory)

      Dir.chdir root_directory
      output = %x[ git log -p -1 #{opt[:git_params]} 2>&1 ]
      output = output.gsub(/git <command>/, COMMAND_NAME)
      raise StandardError, output unless output !~ /^fatal:/
    ensure
      Dir.chdir cwd
    end
  end

  private
    def self.set_default_options opt = {}
      opt[:git_params] |= ""
      opt[:format] |= ""
      opt[:compute] |= ""
    end
end
