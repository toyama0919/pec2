require 'spec_helper'
require 'pec2'

describe Pec2 do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).to_not be_empty
  end
end
