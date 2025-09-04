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
FactoryBot.define do
    factory :cart do
      total_price { 0 }
      abandoned { false }
    end
end
