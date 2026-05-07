class CreateOrderItems < ActiveRecord::Migration[5.1]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true
      t.string :name
      t.string :size
      t.text :add
      t.text :remove

      t.timestamps
    end
  end
end
