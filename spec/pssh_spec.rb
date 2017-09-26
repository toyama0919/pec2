require 'spec_helper'
require 'pec2'
require 'tempfile'

describe Pec2::Pssh do
  before do
    @tf = Tempfile.open("pec2") { |fp|
      fp.puts("127.0.0.1")
      fp
    }
    @pssh = Pssh.new({}, @tf.path)
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
    @tf.close
  end
end
