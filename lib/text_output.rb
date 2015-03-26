class TextOutput
  def self.affected_lines result
    if result.is_a? Hash
      "%-14s %d\n" % ["Affected lines:", result[:affected_lines]]
    else
      "%-14s %d\n" % ["Affected lines:", result]
    end
  end

  def self.interactive_lines result
    "%-14s %d\n" % ["Interactive lines:", result]
  end

  def self.standard result
    if result.is_a? Hash
      "%-14s %d\n" % ["Commits:", result[:commits]] +
      "%-14s %d\n" % ["Total Churn:", result[:insertions] + result[:deletions]] +
      "%-14s %d\n" % ["Lines added:", result[:insertions]] +
      "%-14s %d\n" % ["Lines deleted:", result[:deletions]]
    else
      "%-14s %d\n" % ["Standard churn:", result]
    end
  end
end
