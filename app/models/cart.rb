# == Schema Information
#
# Table name: carts
#
#  id          :bigint           not null, primary key
#  total_price :decimal(17, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def to_response
    {
      id: id,
      products: cart_items.includes(:product).map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
          total_price: item.quantity * item.product.price
        }
      end,
      total_price: total_price
    }
  end

  def update_total!
    new_total = cart_items.sum { |item| item.quantity * item.product.price }

    update!(total_price: new_total)
  end
end
