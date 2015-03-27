require 'spec_helper'
require 'set'

describe "TextFormatter class" do
  it "prints as text" do
    h = {"Commits:" => 10, "Affected lines:" => 5}
    expect(TextFormatter.print(h)).to eq("Commits:        10\nAffected lines: 5\n")
  end
end
