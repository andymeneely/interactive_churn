class JsonOutput
  def self.affected_lines result
    Oj.dump({ 'Affected lines' => result[:affected_lines]})
  end

  def self.standard result
    Oj.dump({'Commits' => result[:commits],
             'Total Churn' => result[:insertions] + result[:deletions],
             'Lines added' => result[:insertions],
             'Lines deleted' => result[:deletions]})
  end
end
