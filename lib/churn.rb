require 'oj'
require_relative './output'

class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute opt = {}
    count_lines_from git_history_summary opt[:git_params]
  end

  def self.get_output opt = {}
    Output.as (Churn::compute opt), opt[:format]
  end

  def self.count_lines_from output
    insertions = 0
    deletions = 0
    commits = 0
    output.each do |msg|
      c = msg.match(/^\s\d*\sfiles?\schanged(,\s(\d*) insertions?\(\+\))?(,\s(\d*) deletions?\(\-\))?$/).captures
      insertions += c[1].to_i
      deletions += c[3].to_i
      commits += 1
    end
    {commits: commits, insertions: insertions, deletions: deletions}
  end

  def self.git_history_summary cmd_line_params = ""
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      check_exceptions cmd_line_params
      %x[ git log --no-merges --stat #{cmd_line_params} | grep "^ [0-9]* file" ].split(/\n/)
    rescue Errno::ENOENT
      raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory"
    ensure
      Dir.chdir cwd
    end
  end

  def self.git_history cmd_line_params = ""
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      check_exceptions cmd_line_params
      %x[ git log --no-merges --stat --reverse --unified=0 #{cmd_line_params} | grep -E "Author:|diff|@@.*@@" ].split(/\n/)
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

end
