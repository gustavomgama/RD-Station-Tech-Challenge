# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  quantity   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_cart_items_on_cart_id     (cart_id)
#  index_cart_items_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (product_id => products.id)
#
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates_numericality_of :quantity, greater_than_or_equal_to: 0

  validates :product_id, uniqueness: {
    scope: :cart_id,
    message: "already exists in this cart"
  }

  after_save :update_cart_total
  after_destroy :update_cart_total
  after_commit :touch_cart

  private

  def update_cart_total
    cart.update_total! if cart.present?
  end

  def touch_cart
    cart.touch if cart.present?
  end
end
