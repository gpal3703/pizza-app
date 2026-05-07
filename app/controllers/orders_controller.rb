class OrdersController < ApplicationController
  def index
    @orders = Order.open.order(created_at: :asc)
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(state: 'COMPLETED')
      respond_to do |format|
        format.html { redirect_to orders_path, notice: 'Order was successfully completed.' }
        format.js   # For AJAX support
      end
    else
      redirect_to orders_path, alert: 'Failed to complete order.'
    end
  end
end
