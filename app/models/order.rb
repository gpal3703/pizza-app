class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  serialize :promotion_codes, Array

  scope :open, -> { where(state: 'OPEN') }

  def total_price
    OrderPricingService.new(self).calculate_total
  end
end
