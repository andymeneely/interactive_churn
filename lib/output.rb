class Output
  def self.as result, opt
    if(opt[:compute] == '--affected-lines')
      case opt[:format]
      when nil
        Output::affected_lines_as_text result
      when '--json'
        Output::affected_lines_as_json result
      else
        "churn: #{format} option cannot be interpreted"
      end
    else
      case opt[:format]
      when nil
        Output::as_text result
      when '--json'
        Output::as_json result
      else
        "churn: #{format} option cannot be interpreted"
      end
    end
  end

  def self.affected_lines_as_text result
    "%-14s %d\n" % ["Affected lines:", result[:affected_lines]]
  end

  def self.as_text result
    "%-14s %d\n" % ["Commits:", result[:commits]] +
    "%-14s %d\n" % ["Total Churn:", result[:insertions] + result[:deletions]] +
    "%-14s %d\n" % ["Lines added:", result[:insertions]] +
    "%-14s %d\n" % ["Lines deleted:", result[:deletions]]
  end

  def self.affected_lines_as_json result
    Oj.dump({ 'Affected lines' => result[:affected_lines]})
  end

  def self.as_json result
    Oj.dump({'Commits' => result[:commits],
             'Total Churn' => result[:insertions] + result[:deletions],
             'Lines added' => result[:insertions],
             'Lines deleted' => result[:deletions]})
  end
end
