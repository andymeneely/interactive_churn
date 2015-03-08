require 'oj'
require 'set'
require_relative './output'

class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute opt = {}
    case opt[:compute]
    when '--affected-lines'
      count_affected_lines_from git_history opt[:git_params]
    else
      count_lines_from git_history_summary opt[:git_params]
    end
  end

  def self.get_output opt = {}
    Output.as (Churn::compute opt), opt
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

  def self.count_affected_lines_from output
    author = ""
    previous_author = output[0].match(/^Author:.(.*$)/).captures
    affected_lines = 0
    set = Set.new
    current_file = ""
    current_files = {}
    is_affected = false

    output.each do |msg|
      author = msg.match(/^Author:.(.*$)/)
      if author.nil?
        file  = msg.match(/^diff.*b\/(.*)$/)
        if file.nil?
          set |= get_set_from msg
        else
          old_set = current_files[current_file]
          affected_lines += (old_set & set).size if is_affected && !old_set.nil?
          current_files[current_file] = set.clone
          current_file = file.captures[0]
          set.clear
        end
      else
        author = author.captures
        is_affected = author != previous_author
        previous_author = author
      end
    end

    old_set = current_files[current_file]
    affected_lines += (old_set & set).size if(is_affected && !old_set.nil?)

    {affected_lines: affected_lines}
  end

  def self.get_set_from positions_lengths
    match = positions_lengths.match(/^@@\s-(\d*),?(\d)?\s\+(\d*),?(\d)?\s@@/)
    set = Set.new
    if !match.nil?
      del_pos, del_length, ins_pos, ins_length = match.captures
      del_pos = del_pos.to_i
      ins_pos = ins_pos.to_i
      del_length = "1" if del_length.nil?
      del_length = del_length.to_i
      ins_length = "1" if ins_length.nil?
      ins_length = ins_length.to_i
      set |= (del_pos..(del_pos + del_length - 1)) unless del_length == 0
      set |= (ins_pos..(ins_pos + ins_length - 1)) unless ins_length == 0
    end
    set
  end

  private
    def self.check_exceptions cmd_line_params
      output = %x[ git log -p -1 #{cmd_line_params} 2>&1 ]
      output = output.gsub(/git <command>/, COMMAND_NAME)
      raise StandardError, output unless output !~ /^fatal:/
    end

end
