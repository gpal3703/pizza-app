require 'rails_helper'

RSpec.describe OrderPricingService do
  let(:order) { Order.create!(uuid: 'test-uuid', state: 'OPEN') }

  describe '#calculate_total' do
    it 'calculates basic pizza price' do
      order.order_items.create!(name: 'Margherita', size: 'Medium', add: [], remove: [])
      # Margherita: 5, Medium: 1
      expect(OrderPricingService.new(order).calculate_total).to eq(5.0)
    end

    it 'applies size multiplier' do
      order.order_items.create!(name: 'Margherita', size: 'Large', add: [], remove: [])
      # Margherita: 5, Large: 1.3 => 6.5
      expect(OrderPricingService.new(order).calculate_total).to eq(6.5)
    end

    it 'adds ingredient prices with multiplier' do
      order.order_items.create!(name: 'Margherita', size: 'Large', add: ['Cheese'], remove: [])
      # Margherita: 5, Cheese: 2, Large: 1.3 => (5+2)*1.3 = 9.1
      expect(OrderPricingService.new(order).calculate_total).to eq(9.1)
    end

    it 'applies 2FOR1 promotion' do
      order.update!(promotion_codes: ['2FOR1'])
      2.times do
        order.order_items.create!(name: 'Salami', size: 'Small', add: [], remove: [])
      end
      # Salami: 6, Small: 0.7 => 4.2 each. Total 8.4
      # 2FOR1: one is free (base only). Free item = 0 * 0.7. Paid item = 6 * 0.7 = 4.2
      expect(OrderPricingService.new(order).calculate_total).to eq(4.2)
    end

    it 'still charges for ingredients on free promotion items' do
      order.update!(promotion_codes: ['2FOR1'])
      order.order_items.create!(name: 'Salami', size: 'Small', add: ['Onions'], remove: [])
      order.order_items.create!(name: 'Salami', size: 'Small', add: [], remove: [])
      # Salami: 6, Onions: 1, Small: 0.7
      # Item 1: (0 + 1) * 0.7 = 0.7 (assuming item 1 is free)
      # Item 2: (6 + 0) * 0.7 = 4.2
      # Total: 4.9
      expect(OrderPricingService.new(order).calculate_total).to eq(4.9)
    end

    it 'applies discount code' do
      order.update!(discount_code: 'SAVE5')
      order.order_items.create!(name: 'Margherita', size: 'Medium', add: [], remove: [])
      # Margherita: 5, SAVE5: 5% off => 5 - 0.25 = 4.75
      expect(OrderPricingService.new(order).calculate_total).to eq(4.75)
    end
  end
end
