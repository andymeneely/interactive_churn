class Churn
  COMMAND_NAME = "ichurn"

  class << self
    attr_accessor :root_directory
  end

  def self.compute
    raise StandardError, "#{Churn::COMMAND_NAME}: #{Churn.root_directory}: No such file or directory" unless Dir.exists?(root_directory)
  end

end
