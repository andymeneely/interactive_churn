require 'spec_helper'

describe "Churn" do
  it "has a constant that stores the command name" do
    expect(Churn::COMMAND_NAME).to match(/^ichurn$/)
  end

  it "raises an exception if root_directory is not a directory" do
    directory_name = "not_a_directory"
    Churn.root_directory = directory_name
    expect { Churn.compute }.to raise_error(StandardError, "ichurn: #{directory_name}: No such file or directory")
  end
end
