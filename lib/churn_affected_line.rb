require 'churn'

# A class responsible to compute affected line code churn metric.
class ChurnAffectedLine < Churn

  # Initializes a new instance of Churn with a directory as aparam. By default, the current working directory is set.
  # @params wd: a string with the path of a directory.
  def initialize wd = Dir.getwd
    super
    @prior_commit = {author: "", sets: [Set.new, Set.new]}
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
  # def capture_lines patch_match
  #   return nil if patch_match.nil?

  #   array = capture_all_lines(patch_match)
  #   del = [array[0], array[0] + array[1] - 1] if array[1] > 0
  #   ins = [array[2], array[2] + array[3] - 1] if array[3] > 0
  #   [del, ins]
  # end
  def capture_lines patch_match
    # return nil if patch_match.nil?
    # puts "PATCH---------------- #{patch_match}"
    array = capture_all_lines(patch_match)
    del = ins = Set.new
    del = Set.new(array[0]..array[0] + array[1] - 1) if array[1] > 0
    ins = Set.new(array[2]..array[2] + array[3] - 1) if array[3] > 0
    [del, ins]
  end

  # Counts affected lines, this is deleted or inserted lines that were touched by other author.
  # It is a method call from the template method: Churn#compute. It is called for each patch for a file and commit in the log.
  # @param commit [String] The commit SHA-1 as astring.
  # @param author [String] The author of the commit.
  # @param file [String] The file involved in the commit.
  # @@param sets [[Set, Set],..] An array of sets with lines deleted and lines inserted respectively.
  # @return [Integer] The total affected line churn for a file in a commit.
  def count(commit, author, file, sets)
    affected_lines = 0
    # puts "SETS------------------>#{sets}"
    # puts "PRIOR----------------->#{@prior_commit[:sets]}"
    
    ai = Set.new
    ad = Set.new
    unless sets.empty?
      sets.each do |i, d|
        ad |= d
        ai |= i
        affected_lines += ((i | d) & (@prior_commit[:sets][0]|@prior_commit[:sets][1])).size if(author != @prior_commit[:author])
      end
    end
    @prior_commit[:author] = author
    @prior_commit[:sets] = [ad, ai]
    
    affected_lines
  end

  # Tells OutputFormatter object what to print out.
  # @param output_formatter [OutputFormatter] An object responsible to print in different formats.
  # @return [String] The total commits, affected lines churn.
  def print output_formatter
    output_formatter.print({ "Commits:" => @commits, "Affected lines churn:" => @result})
  end
end
