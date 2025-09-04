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
  describe '#mark_as_abandoned!' do
    let(:cart) { create(:cart, abandoned: false) }

    it 'sets abandoned to true' do
      expect { cart.mark_as_abandoned! }
        .to change { cart.abandoned? }
        .from(false).to(true)
    end
  end

  describe '#active?' do
    it 'returns true when not abandoned' do
      cart = build(:cart, abandoned: false)
      expect(cart.active?).to be true
    end

    it 'returns false when abandoned' do
      cart = build(:cart, abandoned: true)
      expect(cart.active?).to be false
    end
  end

  describe '#recently_active?' do
    it 'returns true when updated within 3 hours' do
      cart = build(:cart, updated_at: 2.hours.ago)
      expect(cart.recently_active?).to be true
    end

    it 'returns false when updated more than 3 hours ago' do
      cart = build(:cart, updated_at: 4.hours.ago)
      expect(cart.recently_active?).to be false
    end
  end
end
