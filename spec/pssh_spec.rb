require 'spec_helper'
require 'pec2'

describe Pec2::Pssh do
  before do
    @pssh = Pssh.new({}, ["127.0.0.1"])
  end

  it "test exec_pssh_command empty" do
    ret = @pssh.exec_pssh_command('')

    expect(ret).to eq(false)
  end

  it "test exec_pssh_command nil" do
    ret = @pssh.exec_pssh_command(nil)

    expect(ret).to eq(false)
  end

  after do
  end
end
