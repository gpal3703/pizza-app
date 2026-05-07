class OrderItem < ApplicationRecord
  belongs_to :order
  serialize :add, Array
  serialize :remove, Array
end
