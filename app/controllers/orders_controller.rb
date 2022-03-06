class OrdersController < ApplicationController
  
  def index
    # Show all orders for the current user
    # Returns an array of orders for the user
    @orders = Order.where(client_id: current_user.id)

    # Returns an array of order ids
    order_ids = @orders.pluck(:id).uniq

    # Searches the order items for a matching id, returns an array of order item_label_class
    # for all orders. 
    @order_items = OrderItem.where(order_id: order_ids)

    service_ids = @order_items.pluck(:id).uniq
    @services = Service.where(id: service_ids)
    # raise
  end
  
  def show
    @order = Order.find(params[:id])
    @seamstress = @order.seamstress
    @services = @order.order_items.map(&:service)
    @total = 0
    @services.each do |s|
      @total += s.price
    end
  end

  def create
    @order = Order.new(order_params)
    @seamstress = User.find(params[:user_id])
    @order.client = current_user
    @order.seamstress = @seamstress
    if @order.save
      redirect_to order_path(@order)
    else
      @errors = @order.errors.messages
      @message = @errors.values.flatten[0]
      render "users/show"
    end
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(drop_time_params)
      redirect_to order_path(@order)
    else
      render :show
    end
  end

  private

  def drop_time_params
    params.require(:order).permit(:drop_time)
  end

  def order_params
    params.require(:order).permit(order_items_attributes: [:service_id])
  end
end
