require 'json'

file_path = Rails.root.join('data', 'orders.json')
orders_data = JSON.parse(File.read(file_path))

orders_data.each do |data|
  order = Order.create!(
    uuid: data['id'],
    state: data['state'],
    created_at: data['createdAt'],
    promotion_codes: data['promotionCodes'],
    discount_code: data['discountCode']
  )

  data['items'].each do |item_data|
    order.order_items.create!(
      name: item_data['name'],
      size: item_data['size'],
      add: item_data['add'],
      remove: item_data['remove']
    )
  end
end

puts "Imported #{Order.count} orders."
