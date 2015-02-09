class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute revision=""
    cwd = Dir.getwd

    raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory" unless Dir.exists?(root_directory)

    Dir.chdir root_directory
    output = %x[ git rev-parse --is-inside-work-tree #{root_directory} 2>&1 ].tr("\n","")
    Dir.chdir cwd
    raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^true/

    Dir.chdir root_directory
    output = %x[ git log -p -1 2>&1 ].tr("\n","")
    Dir.chdir cwd
    raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^commit/

    Dir.chdir root_directory
    output = %x[ git log -p -1 #{revision} 2>&1 ].split(/\n/)[0]
    Dir.chdir cwd
    raise StandardError, "ichurn: " + output unless output =~ /^commit/

  end

end
