require_relative './churn'
require_relative './output'

class ChurnStandard < Churn

  def self.compute opt = {}
    super opt
    count_lines_from git_history_summary opt[:git_params]
  end

  def self.get_output opt = {}
    Output.as (ChurnStandard::compute opt), opt
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
      %x[ git log --no-merges --stat #{cmd_line_params} | grep -E "^\s[0-9]+\sfiles?\s" ].split(/\n/)
    ensure
      Dir.chdir cwd
    end
  end

end
