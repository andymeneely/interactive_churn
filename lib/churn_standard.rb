require 'churn'

# A class respomnsible to compute standard code churn metric.
class ChurnStandard < Churn

  # Captures lines nedeed to compute a standard churn from a regular expression match of git patch-at line like `@@ -a,b +c,d @@`.
  # It is a method call from the template method: Churn#compute
  # * Params:
  # patch_match: a MatchData resulted from the match method invoked in a string.
  # * Return:
  # An array of integer corresponding to length of deleted and inserted lines, e.i.:
  #   from "@@ -1,2 +3,4 @@" it returns [2, 4]
  def capture_lines patch_match
    return nil if patch_match.nil?

    array = capture_all_lines(patch_match)
    [array[1], array[3]]
  end

  # Counts deleted and inserted lines.
  # It is a method call from the template method: Churn#compute. It is called for each file for each commit in the log.
  # * Params:
  # commit: the commit SHA-1.
  # author: the author of the commit.
  # file: the the file changed in the commit.
  # lines_ins_del: and array with length of lines inserted and deleted.
  # * Return:
  # The total churn for a file in a commit.
  def count(commit, author, file, lines_ins_del)
    churn = 0
    unless lines_ins_del.empty?
      lines_ins_del.each do |i, d|
        churn += i + d
      end
    end
    churn
  end
end
