require "rails_helper"

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  subject(:job) { described_class.new }

  let!(:recent_cart) { create(:cart, updated_at: 1.hour.ago, abandoned: false) }
  let!(:old_cart) { create(:cart, updated_at: 4.hours.ago, abandoned: false) }
  let!(:very_old_abandoned) { create(:cart, updated_at: 8.days.ago, abandoned: true) }

  describe "#perform" do
    context "when cart is old" do
      it "marks the cart as abandoned" do
        expect { job.perform }
          .to change { old_cart.reload.abandoned }.from(false).to(true)
      end
    end

    context "when cart is recently active" do
      it "keeps the cart active" do
        expect { job.perform }
          .not_to change { recent_cart.reload.abandoned }
      end
    end

    context "when cart is very old and already abandoned" do
      it "deletes the cart" do
        expect { job.perform }
          .to change { Cart.exists?(very_old_abandoned.id) }.from(true).to(false)
      end
    end
  end
end
