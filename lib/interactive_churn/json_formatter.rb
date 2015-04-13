class JsonFormatter

  def self.print h
    Oj.dump h
  end
end
