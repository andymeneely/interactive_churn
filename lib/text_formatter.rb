class TextFormatter
  FORMAT = "%-15s %d\n"

  def self.print h
    h.map do |k, v|
      FORMAT % [k, v]
    end.join
  end
end
