require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe "#perform" do
    let!(:recent_cart) { create(:cart, updated_at: 1.hour.ago, abandoned: false) }
    let!(:old_cart) { create(:cart, updated_at: 4.hours.ago, abandoned: false) }
    let!(:very_old_abandoned) { create(:cart, updated_at: 8.days.ago, abandoned: true) }

    it "marks old carts as abandoned" do
      expect { subject.perform }
        .to change { old_cart.reload.abandoned }.to(true)
    end

    it "keeps recent carts active" do
      expect { subject.perform }
        .not_to change { recent_cart.reload.abandoned }
    end

    it "deletes very old abandoned carts" do
      expect { subject.perform }
        .to change { Cart.exists?(very_old_abandoned.id) }.to(false)
    end
  end
end
