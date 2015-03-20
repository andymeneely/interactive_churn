require_relative './churn'

class ChurnInteractive < Churn

  def self.compute opt = {}
    super opt
    count_interactive_lines_from git_history opt[:git_params]    
  end

  def self.git_history cmd_line_params = ""
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      # it returns commit SHA, author, diff with filename, and @@.*@@ lines per file for each commit made
      %x[ git log --ignore-all-space --reverse --unified=0 #{cmd_line_params} | grep -E "^(commit\s[[:alnum:]]{40}$|Author:\s|diff\s--git\sa|@@\s\-[0-9]+(,[0-9]+)?\s\+[0-9]*(,[0-9]+)?.*@@)" ].split(/\n/)
    rescue Errno::ENOENT
      raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory"
    ensure
      Dir.chdir cwd
    end
  end

  def self.count_interactive_lines_from output
    current_commit = ""
    current_author = ""
    current_file = ""
    affected_lines = 0

    output.each do |line|
      commit_match = line.match(/^commit\s(\w*)$/)
      unless commit_match.nil?
        current_commit = commit_match.captures[0]
      end

      author_match = line.match(/^Author:\s(.*)\s</)
      unless author_match.nil?
        current_author = author_match.captures[0]
      end

      file_match = line.match(/^diff\s--git\sa\/.*\sb\/(.*)$/)
      unless file_match.nil?
        current_file = file_match.captures[0]
      end

      at_match = line.match(/^@@\s-(\d*),?(\d*)?\s\+(\d*),?(\d*)?\s@@/)
      unless at_match.nil?
        del_start_end = get_array_of_start_end_delition line
        affected_lines += count_interactive_lines_from_blame( current_commit, current_author, current_file, del_start_end) unless del_start_end.nil?
      end
    end
    {interactive_lines: affected_lines}
  end

  def self.count_interactive_lines_from_blame( current_commit, current_author, current_file, del_start_end) 
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      start_del = del_start_end[0]
      end_del = del_start_end[1]
      affected_lines = 0
      blame = %x[ git blame -l -L #{start_del},#{end_del} #{current_commit}^ -- #{current_file} ]
      blame.each_line do |line|
        orig_author = line.match(/\((.*)\s\d\d\d\d/).captures[0]
        affected_lines += 1 if(current_author != orig_author)
      end
      affected_lines
    ensure
      Dir.chdir cwd
    end
  end

  def self.get_array_of_start_end_delition positions_lengths
    match = positions_lengths.match(/^@@\s-(\d*),?(\d*)?\s\+(\d*),?(\d*)?\s@@/)
    array = nil
    unless match.nil?
      del_pos, del_length, ins_pos, ins_length = match.captures
      del_pos = del_pos.to_i
      del_length = "1" if del_length.empty?
      del_length = del_length.to_i
      if del_length > 0
        array = []
        array.push( del_pos)
        array.push( del_pos + del_length -1)
      end
    end
    array
  end

end
