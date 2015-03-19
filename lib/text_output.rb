class TextOutput
  def self.affected_lines result
    "%-14s %d\n" % ["Affected lines:", result[:affected_lines]]
  end

  def self.interactive_lines result
    "%-14s %d\n" % ["Interactive lines:", result[:interactive_lines]]
  end

  def self.standard result
    "%-14s %d\n" % ["Commits:", result[:commits]] +
    "%-14s %d\n" % ["Total Churn:", result[:insertions] + result[:deletions]] +
    "%-14s %d\n" % ["Lines added:", result[:insertions]] +
    "%-14s %d\n" % ["Lines deleted:", result[:deletions]]
  end
end
