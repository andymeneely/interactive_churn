require 'oj'
require 'set'
require 'git_cmd'

# A base class with a template method to run an algorithm to process `git log` output to compute different code churn metrics.
class Churn
  # A string with the name of the command line.
  COMMAND_NAME = "ichurn"
  # A string with a regular expresion to match a group with the commit ID from the line of `git log` with the commit SHA-1.
  COMMIT_SHA   = /^commit\s(\w*)$/
  # A string with a regular expresion to match a group with the author from `git log` line where author appears.
  AUTHOR       = /^Author:\s(.*)\s</
  # A string with a regular expresion to match a group with the author from `git blame` line where author appears.
  AUTHOR_BLAME = /\((.*)\s\d\d\d\d/
  # A string with a regular expresion to match a group with the file from `git log` line where file appears.
  FILE         = /^diff\s--git\sa\/.*\sb\/(.*)$/
  # A string with a regular expresion to match groups for each number in the patch-at line from `git log`.
  PATCH_AT     = /^@@\s-(\d*),?(\d*)?\s\+(\d*),?(\d*)?\s@@/

  # Initializes a new instance of Churn with a directory as aparam. By default, the current working directory is set.
  # * Params:
  # wd: a string with the path of a directory.
  def initialize dir = Dir.getwd
    @git = GitCmd.new(dir)
  end

  # Captures all lines from a regular expression match of git patch-at `@@ -a,b +c,d @@` line.
  # * Params:
  # patch_match: a MatchData resulted from the match method invoked in a string.
  # * Return:
  # An array of integer corresponding to the lines stated in the patch at line, e.i.:
  #   from "@@ -1,2 +3,4 @@" it returns [1, 2, 3, 4]
  def capture_all_lines patch_match
    return nil if patch_match.nil?

    del_pos, del_length, ins_pos, ins_length = patch_match.captures
    del_pos = del_pos.to_i
    del_length = "1" if del_length.empty?
    del_length = del_length.to_i

    ins_pos = ins_pos.to_i
    ins_length = "1" if ins_length.empty?
    ins_length = ins_length.to_i

    [del_pos, del_length, ins_pos, ins_length]
  end

  # Template method to compute different types of churn metric.
  # * Params:
  # git_params: a string with options that `git log` understands, for example:
  #   "HEAD^", or "HEAD^^..HEAD", or "55ce17208d", or "HEAD -- *.rb",  etc.
  # * Return:
  # A number representing the code churn metric computed.
  def compute git_params = ""
    churn = 0

    logs = @git.log(git_params).split(/\n/)

    top = logs.shift
    while top != nil

      commit = top.match(COMMIT_SHA).captures.first

      top = logs.shift
      author = top.match(AUTHOR).captures.first

      top = logs.shift
      while top != nil && (file_match = top.match(FILE)) != nil
        file = file_match.captures.first

        top = logs.shift
        lines_ins_del = []
        while top != nil && (patch_match = top.match(PATCH_AT)) != nil
          lines_ins_del << capture_lines(patch_match)
          top = logs.shift
        end

        churn += count(commit, author, file, lines_ins_del.compact)
      end
    end
    churn
  end
end
