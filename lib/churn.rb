class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute revision=""
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      check_exceptions revision
    rescue Errno::ENOENT
      raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory"
    rescue StandardError => e
      raise e
    ensure
      Dir.chdir cwd
    end
  end

  private
    def self.check_exceptions revision
      output = %x[ git rev-parse --is-inside-work-tree #{root_directory} 2>&1 ].tr("\n","")
      raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^true/

      output = %x[ git log -p -1 2>&1 ].tr("\n","")
      raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^commit/

      output = %x[ git log -p -1 #{revision} 2>&1 ].split(/\n/)[0]
      raise StandardError, "ichurn: " + output unless output =~ /^commit/
    end

end
