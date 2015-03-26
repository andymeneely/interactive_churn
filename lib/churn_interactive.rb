require 'churn'
require 'set'

# A class responsible to compute interactive code churn metric.
class ChurnInteractive < Churn

  # Attribute to get the number of lines deleted of the same author.
  attr_reader :self_churn
  # Attribute to get the number of original authors affected.
  attr_reader :authors_affected

  # Initializes a new instance of ChurnInteractive.
  # @params wd: a string with the path of a directory.
  def initialize wd = Dir.getwd
    super
    @authors_affected = 0
    @self_churn = 0
  end

  # Captures lines nedeed to compute interactive churn from a regular expression match of git patch-at line like `@@ -a,b +c,d @@`.
  # It is a method call from the template method: Churn#compute
  # * Params:
  # patch_match: a MatchData resulted from the match method invoked in a string, e.g.:
  #  "@@ -1,2 +3,4 @@".match(ChurnInteractive::PATCH_AT)
  # * Return:
  # An array of integer corresponding to the start and end line of deletion, e.i.:
  #   from "@@ -3,3 +8,2 @@" it returns [3, 5]
  # if the length of deletion is 0, it return nil.
  def capture_lines patch_match
    return nil if patch_match.nil?

    array = capture_all_lines(patch_match)
    [array[0], array[0] + array[1] - 1] if array[1] > 0
  end

  # Counts interactive lines, this is lines deleted that were writen by other author.
  # It is a method call from the template method: Churn#compute. It is called for each file for each commit in the log.
  # * Params:
  # commit: the commit SHA-1.
  # author: the author of the commit.
  # file: the the file changed in the commit.
  # lines_ins_del: and array with length of lines inserted and deleted.
  # * Return:
  # The total interactive churn (or affected lines) for a file in a commit.
  def count(commit, author, file, lines_del)
    interactive_lines = 0
    a = Set.new
    unless lines_del.empty?
      @git.blame(file, "#{commit}^", lines_del).each_line do |line|
        orig_author = line.match(AUTHOR_BLAME).captures[0]
        if(orig_author != author)
          a.add orig_author
          interactive_lines += 1
        else
          @self_churn += 1
        end
      end
    end
    @authors_affected += a.size
    interactive_lines
  end
end
