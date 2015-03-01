class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute with_command_line_params = ""
    count_lines_from git_history_summary with_command_line_params
  end

  def self.get_output cmd_line_params = ""
    result = Churn::compute cmd_line_params
    "%-14s %d\n" % ["Commits:", result[:commits]] +
    "%-14s %d\n" % ["Total Churn:", result[:insertions] + result[:deletions]] +
    "%-14s %d\n" % ["Lines added:", result[:insertions]] +
    "%-14s %d\n" % ["Lines deleted:", result[:deletions]]
  end

  def self.count_lines_from output
    insertions = 0
    deletions = 0
    commits = 0
    output.each do |msg|
      commits += 1 if(msg =~ /file/)
      matching = msg.match(/(\d*) insertion.*/)
      insertions += matching.nil? ? 0 : matching[1].to_i
      matching = msg.match(/(\d*) deletion.*/)
      deletions += matching.nil? ? 0 : matching[1].to_i
    end
    {commits: commits, insertions: insertions, deletions: deletions}
  end

  def self.git_history_summary cmd_line_params = ""
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      check_exceptions cmd_line_params
      %x[ git log --no-merges --stat #{cmd_line_params} | grep "^ [0-9]* file" ].split(/,|\n/)
    rescue Errno::ENOENT
      raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory"
    ensure
      Dir.chdir cwd
    end
  end

  private
    def self.check_exceptions cmd_line_params
      output = %x[ git log -p -1 #{cmd_line_params} 2>&1 ]
      output = output.gsub(/git <command>/, COMMAND_NAME)
      raise StandardError, output unless output !~ /^fatal:/
    end

    def self.set_default_parameters opt
      opt[:revision] ||= 'HEAD'
      opt[:file_name] ||= ''
    end

end
