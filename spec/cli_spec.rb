require 'spec_helper'
require 'pec2'

describe Pec2::CLI do
  before do
    ENV['AWS_REGION'] = 'us-east-1'
  end

  it "should stdout sample" do
    output = capture_stdout do
      Pec2::CLI.start(['help'])
    end
    expect(output).not_to eq(nil)
  end

  it "include" do
    output = capture_stdout do
      Pec2::CLI.start(['help', 'run_command'])
    end
    expect(output).to include('--command')
    expect(output).to include('--sudo-password')
    expect(output).to include('--tag')
    expect(output).to include('--user')
    expect(output).to include('--parallel')
    expect(output).to include('--print')
  end

  after do
  end
end
