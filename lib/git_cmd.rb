require 'open3'
require 'rugged'

# A class to execute `git log` and `git blame` command
class GitCmd
  # A string storing `git` to be used when execcuting the `git`command.
  GIT_CMD = " git "
  # A string with a regular expresion to match lines of `git log` with the commit SHA-1.
  REGEX_MATCH_COMMIT   = "^commit\s[[:alnum:]]{40}$"
  # A string with a regular expresion to match lines of `git log` where the author name is shown.
  REGEX_MATCH_AUTHOR   = "^Author:\s"
  # A string with a regular expresion to match lines of `git log` where the filename appears.
  REGEX_MATCH_FILE     = "^diff\s--git\sa\/.*\sb\/"
  # A string with a regular expresion to match lines of `git log` where the lines of the patch are shown.
  REGEX_MATCH_PATCH_AT = "^@@\s\-[0-9]+(,[0-9]+)?\s\+[0-9]*(,[0-9]+)?.*@@"

  # Stands for working directory, by default is set to the current working directory.
  attr_accessor :wd

  # Initializes the new instance of GitCmd with a directory. By default, the current working directory is set.
  # @param wd [String] A string with the path of a directory.
  def initialize wd = Dir.getwd
    @wd = wd
  end

  # Runs `git log` command with the following fixed options:
  #   log --ignore-all-space --reverse --unified=0
  # It also filters the result with `grep` command to match commit, author, file, and patch lines @@
  # @param options [String] Options that `git log` understands, like <tt>"HEAD^", "HEAD^^..HEAD", "55ce17208d", "HEAD -- *.rb"</tt>,  etc.
  # @return [String] Result of the execution of `git log --ignore-all-space --reverse --unified=0command .
  def log options = ""
    repo = Rugged::Repository.new(@wd)
    walker = Rugged::Walker.new(repo)
    walker.sorting(Rugged::SORT_REVERSE)
    walker.push("master")
    s = ""
    walker.each do |commit|
      s += "commit #{commit.oid}\n"
      s += "Author: #{commit.author[:name]} <#{commit.author[:email]}>\n"
      commit.diff(:context_lines => 0, :ignore_whitespace => true).each_line do |line|
        if line.line_origin == :file_header
          s += line.content.split(/\n/).first + "\n"
        elsif line.line_origin == :hunk_header
          i,ix,d,dx = line.content.split(/\n/).first.match(/^@@\s-(\d*),?(\d*)?\s\+(\d*),?(\d*)?\s@@/).captures
          dx = (dx.empty?)? "" : ",#{dx}"
          ix = (ix.empty?)? "" : ",#{ix}"
          s += "@@ -#{d}#{dx} +#{i}#{ix} @@\n"
          # s += line.content.split(/\n/).first + "\n"
        end
      end
    end
    walker.reset
    s
  end

  # Runs +git blame+ command for a specific commit and for a given file. By default it runs blame for the entire file in HEAD.
  # @param file [String] Mandatory, a string to specify the file to be blamed.
  # @param commit [String] A string to specify the commit where `git blame` will be executed.
  # @param line_numbers [Array] An array of arrays of pair of integers to specify lines to be shown.
  #   [[1,2],[4,6],[8,9]] will show blame in lines 1, 2, 4, 5, 6, 8, and 9
  # @return [String] A string with the result of the execution of git blame, like the result of +git blame -L 1,2 HEAD -- file.rb+
  def blame file, commit = "", line_numbers = []
    lines = GitCmd.reduce_to_string line_numbers
    commit = commit + " -- " unless commit.empty?
    execute "blame #{lines} #{commit} #{file}"
  end

  # Reduces an array of integers pairs into a string to be used in a <tt>git blame</tt> command.
  #   [[1,2],[4,6],[8,9]] becomes "-L 1,2 -L 4,6 -L 8,9 "
  # @param arr [Array< Array< Integer, Integer>>] An array of arrays with pairs of integers.
  # @return [String] A string to be used in a +git blame+ command.
  def self.reduce_to_string arr
    arr.reduce(""){ |s, e| s += "-L #{e[0]},#{e[1]} "}
  end

  # Executes +git+ command with the sub-command passed as argument.
  # @param sub_cmd [String] A string for the +log+ or +blame+ git subcommand.
  # @return [String] A string with the result of the execution of the git command.
  # @raise [StandardError] Raises an +StandardError+ if the git command is not successful executed. The message will be the resulted message from +git+ command.
  def execute sub_cmd
    cwd = Dir.getwd
    Dir.chdir @wd
    result = nil
    begin
      Open3.popen3(GIT_CMD + sub_cmd) do |i, o, e, t|
        error = e.read
        raise StandardError, error unless (t.value.success? or error.empty?)
        result = o.read
      end
    ensure
      Dir.chdir cwd
    end
  end

end
