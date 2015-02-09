require 'spec_helper'

describe "Churn" do
  it "has a constant that stores the command name" do
    expect(Churn::COMMAND_NAME).to match(/^ichurn$/)
  end
end
