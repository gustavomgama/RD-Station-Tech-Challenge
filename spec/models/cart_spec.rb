# == Schema Information
#
# Table name: carts
#
#  id          :bigint           not null, primary key
#  abandoned   :boolean          default(FALSE), not null
#  total_price :decimal(17, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_carts_on_abandoned                 (abandoned)
#  index_carts_on_abandoned_and_updated_at  (abandoned,updated_at)
#
require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe '#mark_as_abandoned!' do
    let(:cart) { create(:cart, abandoned: false) }

    it 'sets abandoned to true' do
      expect { cart.mark_as_abandoned! }
        .to change { cart.abandoned? }
        .from(false).to(true)
    end
  end

  describe "#active?" do
    context "when not abandoned" do
      it "returns true" do
        cart = build(:cart, abandoned: false)
        expect(cart.active?).to be true
      end
    end

    context "when abandoned" do
      it "returns false" do
        cart = build(:cart, abandoned: true)
        expect(cart.active?).to be false
      end
    end
  end

  describe "#recently_active?" do
    context "when updated within 3 hours" do
      it "returns true" do
        cart = build(:cart, updated_at: 2.hours.ago)
        expect(cart.recently_active?).to be true
      end
    end

    context "when updated more than 3 hours ago" do
      it "returns false" do
        cart = build(:cart, updated_at: 4.hours.ago)
        expect(cart.recently_active?).to be false
      end
    end
  end
end
