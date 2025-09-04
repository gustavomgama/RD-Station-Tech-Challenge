class CartsController < ApplicationController
  before_action :find_cart, only: [:show, :destroy]
  before_action :find_or_create_cart, only: [:create, :update]

  def show
    render json: @cart.to_response
  end

  def create
    add_item(replace: true)
  end

  def update
    add_item(replace: false)
  end

  def destroy
    return render json: { error: "Cart not found" }, status: :not_found unless @cart

    item = @cart.cart_items.find_by(product_id: params[:product_id])
    return render json: { error: "Product not found in cart" }, status: :not_found unless item

    item.destroy
    @cart.touch
    @cart.update_total!

    if @cart.cart_items.empty?
      @cart.destroy
      session[:cart_id] = nil
      return render json: { message: "Cart deleted" }, status: :ok
    end

    render json: @cart.to_response
  end

  private

  def find_cart
    @cart = Cart.find_by(id: session[:cart_id])
    render json: { error: "Cart not found" }, status: :not_found unless @cart
  end

  def find_or_create_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create!(total_price: 0)
    session[:cart_id] = @cart.id
  end

  def add_item(replace:)
    return invalid_quantity if params[:quantity].to_i <= 0

    product = Product.find_by(id: params[:product_id])
    return product_not_found unless product

    Cart.transaction do
      @cart.lock!
      item = @cart.cart_items.find_by(product_id: product.id)
      quantity = params[:quantity].to_i

      if item
        new_qty = replace ? quantity : item.quantity + quantity
        return invalid_quantity if new_qty <= 0
        item.update!(quantity: new_qty)
      else
        @cart.cart_items.create!(product: product, quantity: quantity)
      end

      @cart.touch
      @cart.update_total!
    end

    render json: @cart.to_response
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def invalid_quantity
    render json: { error: "Quantity must be positive" }, status: :unprocessable_entity
  end

  def product_not_found
    render json: { error: "Product not found" }, status: :not_found
  end
end
