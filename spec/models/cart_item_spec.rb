require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'validates numericality of quantity' do
      cart = described_class.new(quantity: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:quantity]).to include("must be greater than or equal to 0")
    end
  end

  describe "callbacks" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    describe "#update_cart_total" do
      context "after save" do
        it "updates the cart total" do
          cart_item = build(:cart_item, cart:, product:)
          expect(cart).to receive(:update_total!)
          cart_item.save
        end
      end

      context "after destroy" do
        it "updates the cart total" do
          cart_item = create(:cart_item, cart:, product:)
          expect(cart).to receive(:update_total!)
          cart_item.destroy
        end
      end
    end

    context "#touch_cart" do
      it "touches the cart" do
        cart_item = build(:cart_item, cart:, product:)

        expect(cart).to receive(:touch)
        cart_item.save
      end
    end
  end
end
