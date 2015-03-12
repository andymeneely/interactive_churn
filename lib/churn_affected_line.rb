require_relative './churn'

class ChurnAffectedLine < Churn

  def self.compute opt = {}
    super opt
    count_affected_lines_from git_history opt[:git_params]
  end

  def self.git_history cmd_line_params = ""
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      # @TODO The commented regex should be more accurate, but it doesn't work. Why?
      # %x[ git log --no-merges --stat --reverse --unified=0 #{cmd_line_params} | grep -E "^(Author:\s|diff\s--git\sa|@@\s\-[0-9]+(,[0-9]+)?\s\+[0-9]+(,[0-9]+)?\s@@)" ].split(/\n/)
      %x[ git log --no-merges --stat --reverse --unified=0 #{cmd_line_params} | grep -E "^(Author:\s|diff\s--git\sa|@@\s\-[0-9]+(,[0-9]+)?\s\+[0-9]*(,[0-9]+)?.*@@)" ].split(/\n/)
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
end
