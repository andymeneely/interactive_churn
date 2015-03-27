require 'spec_helper'
require 'set'

describe "JsonFormatter class" do
  it "prints as json" do
    h = {"Commits:" => 10, "Affected lines:" => 5}
    expect(JsonFormatter.print(h)).to eq("{\"Commits:\":10,\"Affected lines:\":5}")
  end
end
