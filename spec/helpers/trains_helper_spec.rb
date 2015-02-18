require 'rails_helper'

RSpec.describe TrainsHelper, type: :helper do
  describe "percentage" do
    describe "int" do
      it { expect(percentage(1, 5)).to eq "20.00%" }
    end
    describe "float" do
      it { expect(percentage(1, 3)).to eq "33.33%" }
    end
  end
end
