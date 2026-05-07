class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :uuid
      t.string :state
      t.text :promotion_codes
      t.string :discount_code

      t.timestamps
    end
  end
end
