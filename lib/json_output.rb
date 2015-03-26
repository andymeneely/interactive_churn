class JsonOutput
  def self.affected_lines result
    if result.is_a? Hash
      Oj.dump({ 'Affected lines' => result[:affected_lines]})
    else
      Oj.dump({ 'Affected lines' => result})
    end
  end

  def self.interactive_lines result
    Oj.dump({ 'Interactive lines' => result})
  end

  def self.standard result
    if result.is_a? Hash
      Oj.dump({'Commits' => result[:commits],
               'Total Churn' => result[:insertions] + result[:deletions],
               'Lines added' => result[:insertions],
               'Lines deleted' => result[:deletions]})
    else
      Oj.dump({ 'Standard churn' => result})
    end
  end
end
