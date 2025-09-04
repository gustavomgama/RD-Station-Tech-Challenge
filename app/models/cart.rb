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
class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(abandoned: false) }
  scope :abandoned, -> { where(abandoned: true) }
  scope :inactive_since, ->(time) { where('updated_at < ?', time) }

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

  def mark_as_abandoned!
    update!(abandoned: true)
  end

  def active?
    !abandoned?
  end

  def recently_active?
    updated_at > 3.hours.ago
  end

  private

  def touch_updated_at
    touch unless updated_at_changed?
  end
end
