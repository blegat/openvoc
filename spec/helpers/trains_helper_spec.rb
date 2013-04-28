require 'spec_helper'

describe TrainsHelper do
  describe "percentage" do
    describe "int" do
      it { percentage(1, 5).should == "20.00%" }
    end
    describe "float" do
      it { percentage(1, 3).should == "33.33%" }
    end
  end
end
