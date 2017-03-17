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

  it "test build_pssh_command empty" do
    pssh_command = @pssh.build_pssh_command('')

    expect(pssh_command).to include(%Q{-O StrictHostKeyChecking=no})
    expect(pssh_command).to include(%Q{-t 0 -x '-tt'})
    expect(pssh_command).to include(%Q{-i ''})
  end

  it "test build_pssh_command" do
    pssh_command = @pssh.build_pssh_command('hostname')

    expect(pssh_command).not_to start_with(%Q{(echo password) |})
    expect(pssh_command).to include(%Q{-O StrictHostKeyChecking=no})
    expect(pssh_command).to include(%Q{-t 0 -x '-tt'})
    expect(pssh_command).to include(%Q{-i hostname})
  end

  it "test build_pssh_command with user option" do
    pssh = Pssh.new({ user: 'app' }, @tf.path)
    pssh_command = pssh.build_pssh_command('hostname')
    expect(pssh_command).to include(%Q{ -l app})
  end

  it "test build_pssh_command with log option" do
    pssh = Pssh.new({ log: 'hoge.log' }, @tf.path)
    pssh_command = pssh.build_pssh_command('hostname')
    expect(pssh_command).to include(%Q{ -o hoge.log})
  end

  it "test build_pssh_command with parallel option" do
    pssh = Pssh.new({ parallel: 10 }, @tf.path)
    pssh_command = pssh.build_pssh_command('hostname')
    expect(pssh_command).to include(%Q{ -p 10})
  end

  it "test build_pssh_command with print option" do
    pssh = Pssh.new({ print: true }, @tf.path)
    pssh_command = pssh.build_pssh_command('hostname')
    expect(pssh_command).to include(%Q{ -P})
  end

  it "test build_pssh_command with sudo_password option" do
    pssh = Pssh.new({ sudo_password: 'password' }, @tf.path)
    pssh_command = pssh.build_pssh_command('hostname')
    expect(pssh_command).to start_with(%Q{(echo password) |})
  end

  after do
    @tf.close
  end
end
