class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute with_opt = {}
    count_lines_from git_history_summary with_opt
  end

  def self.count_lines_from output
    insertions = 0
    deletions = 0
    output.each do |msg|
      matching = msg.match(/(\d*) insertion.*/)
      insertions += matching.nil? ? 0 : matching[1].to_i
      matching = msg.match(/(\d*) deletion.*/)
      deletions += matching.nil? ? 0 : matching[1].to_i
    end
    {insertions: insertions, deletions: deletions}
  end

  def self.git_history_summary with_opt = {}
    cwd = Dir.getwd
    set_default_parameters with_opt
    begin
      Dir.chdir root_directory
      check_exceptions with_opt[:revision], with_opt[:file_name]
      output = %x[ git rev-list --no-merges #{with_opt[:revision]} | while read rev; do git show -w -C --shortstat --format=format: $rev #{with_opt[:file_name]} | grep file; done 2>&1 ].split(/\n/)
      output.map{|e| e.split(/,/) }.flatten
    rescue Errno::ENOENT
      raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory"
    ensure
      Dir.chdir cwd
    end
  end

  private
    def self.check_exceptions revision, file_name
      output = %x[ git rev-parse --is-inside-work-tree #{root_directory} 2>&1 ].tr("\n","")
      raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^true/

      output = %x[ git log -p -1 2>&1 ].tr("\n","")
      raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^commit/

      output = %x[ git log -p -1 #{file_name} 2>&1 ].split(/\n/)[0]
      raise StandardError, "ichurn: " + output unless output =~ /^commit/

      output = %x[ git log -p -1 #{revision} 2>&1 ].split(/\n/)[0]
      raise StandardError, "ichurn: " + output unless output =~ /^commit/
    end

    def self.set_default_parameters opt
      opt[:revision] ||= 'HEAD'
      opt[:file_name] ||= ''
    end

end
