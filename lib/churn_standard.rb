require 'churn'

# A class respomnsible to compute standard code churn metric.
class ChurnStandard < Churn

  # Attribute to get the number of commits found after compute churn metric.
  attr_reader :insertions, :deletions

  # Initializes a new instance of ChurnStandard with a directory as aparam.
  # @params wd: a string with the path of a directory.
  def initialize wd = Dir.getwd
    super
    @deletions = 0
    @insertions = 0
  end

  # Captures lines nedeed to compute a standard churn from a regular expression match of git patch-at line like `@@ -a,b +c,d @@`.
  # It is a method call from the template method: Churn#compute
  # @param patch_match [MatchData] Resulted match data from the String#match method.
  # @return [Array< Integer, Integer>] An array of integer corresponding to length (number of lines) of deleted and inserted lines, e.i.:
  #   from "@@ -1,2 +3,4 @@" it returns [2, 4]
  def capture_lines patch_match
    return nil if patch_match.nil?

    array = capture_all_lines(patch_match)
    [array[1], array[3]]
  end

  # Counts deleted and inserted lines.
  # It is a method call from the template method: Churn#compute. It is called for each file for each commit in the log.
  # @param commit [String] The commit SHA-1.
  # @param author [String] The author of the commit.
  # @param file [String] The name of the file changed in the commit.
  # @param lines_ins_del [Array< Array <Integer, Integer>>]: An array with the number of lines inserted and deleted.
  # @return [Integer] The total churn for a file in a commit.
  def count(commit, author, file, lines_ins_del)
    churn = 0
    unless lines_ins_del.empty?
      lines_ins_del.each do |d, i|
        @deletions += d
        @insertions += i
        churn += d + i
      end
    end
    churn
  end

  # Tells OutputFormatter object what to print out.
  # @param output_formatter [OutputFormatter] An object responsible to print in different formats.
  # @return [String] The total commits, standard churn, deletions, and insertions.
  def print output_formatter
    output_formatter.print({ "Commits:" => @commits, "Standard churn:" => @result, "Deletions:" => @deletions, "Insertions:" => @insertions })
  end
end
