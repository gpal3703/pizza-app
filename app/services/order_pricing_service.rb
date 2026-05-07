require 'yaml'

class OrderPricingService
  def initialize(order)
    @order = order
    @config = YAML.load_file(Rails.root.join('data', 'config.yml'))
  end

  def calculate_total
    items = @order.order_items.to_a
    total = 0.0

    # Calculate base item prices (including ingredients)
    # We store them in a way that we can apply promotions later
    item_prices = items.map do |item|
      {
        item: item,
        base_pizza_price: @config['pizzas'][item.name] || 0.0,
        ingredients_price: item.add.sum { |ing| @config['ingredients'][ing] || 0.0 },
        multiplier: @config['size_multipliers'][item.size] || 1.0
      }
    end

    # Apply Promotions
    @order.promotion_codes.each do |code|
      promo = @config['promotions'][code]
      next unless promo

      # Find qualifying items
      qualifying_items = item_prices.select do |ip|
        ip[:item].name == promo['target'] && ip[:item].size == promo['target_size']
      end

      # 2FOR1 logic: for every 'from' items, 'to' items are paid, others are free (base price only)
      # e.g., from: 2, to: 1 means 1 free for every 2
      if promo['from'] > promo['to']
        free_count = (qualifying_items.count / promo['from']) * (promo['from'] - promo['to'])
        
        # Mark the cheapest base prices as free (though usually they are the same size)
        # Actually, the requirement says "Extra ingredients will still be charged"
        # So we just zero out the base_pizza_price for the free items
        qualifying_items.take(free_count).each do |ip|
          ip[:base_pizza_price] = 0.0
        end
      end
    end

    # Sum everything up
    total = item_prices.sum do |ip|
      (ip[:base_pizza_price] * ip[:multiplier]) + (ip[:ingredients_price] * ip[:multiplier])
    end

    # Apply Discount
    if @order.discount_code
      discount = @config['discounts'][@order.discount_code]
      if discount
        total -= (total * (discount['deduction_in_percent'] / 100.0))
      end
    end

    total.round(2)
  end
end
