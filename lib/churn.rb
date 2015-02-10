class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute revision="HEAD"
    cwd = Dir.getwd
    begin
      Dir.chdir root_directory
      check_exceptions revision
      output = %x[ git rev-list --no-merges #{revision} | while read rev; do git show -w -C --shortstat --format=format: $rev; done 2>&1 ].split(/\n/)
      output = output.reject{|v| output.index(v).even? }.map{|e| e.split(/,/) }.flatten
      insertions = 0
      output.each do |msg|
        matching = msg.match(/(\d*) insertion.*/)
        insertions += matching.nil? ? 0 : matching[1].to_i
      end
      insertions
    rescue Errno::ENOENT
      raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory"
    ensure
      Dir.chdir cwd
    end
  end

  private
    def self.check_exceptions revision
      output = %x[ git rev-parse --is-inside-work-tree #{root_directory} 2>&1 ].tr("\n","")
      raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^true/

      output = %x[ git log -p -1 2>&1 ].tr("\n","")
      raise StandardError, "ichurn: #{root_directory}: " + output unless output =~ /^commit/

      output = %x[ git log -p -1 #{revision} 2>&1 ].split(/\n/)[0]
      raise StandardError, "ichurn: " + output unless output =~ /^commit/
    end

end
