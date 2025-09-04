require 'rails_helper'

RSpec.describe CartsController, type: :request do
  let!(:product) { create(:product, name: 'Test Product', price: 10.0) }

  describe 'GET #show' do
    context 'when cart exists' do
      let!(:cart) { create(:cart) }

      before do
        allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
        create(:cart_item, cart: cart, product: product, quantity: 2)
        cart.update_total!
      end

      it 'returns the cart' do
        get cart_path
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['id']).to eq(cart.id)
        expect(json['products'].size).to eq(1)
      end
    end

    context 'when cart does not exist' do
      it 'returns error' do
        get cart_path
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Cart not found')
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates cart and adds product' do
        post cart_path, params: { product_id: product.id, quantity: 2 }

        expect(response).to have_http_status(:ok)
        expect(session[:cart_id]).to be_present

        json = JSON.parse(response.body)
        expect(json['products'].first['quantity']).to eq(2)
      end
    end

    context 'with invalid quantity' do
      it 'returns error for zero quantity' do
        post cart_path, params: { product_id: product.id, quantity: 0 }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid product' do
      it 'returns error for non-existent product' do
        post cart_path, params: { product_id: 999, quantity: 1 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #update' do
    let!(:cart) { create(:cart) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
      create(:cart_item, cart: cart, product: product, quantity: 2)
      cart.update_total!
    end

    it 'adds to existing quantity' do
      post "/cart/add_item", params: { product_id: product.id, quantity: 3 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['products'].first['quantity']).to eq(5)
    end
  end

  describe 'DELETE #destroy' do
    let!(:cart) { create(:cart) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
      cart.update_total!
    end

    it 'removes product from cart' do
      delete "/cart/#{cart_item.product.id}", as: :json

      expect(response).to have_http_status(:ok)
      expect(cart.cart_items.exists?(cart_item.id)).to be_falsey
    end

    it 'returns error for non-existent product' do
      delete cart_path, params: { product_id: 999 }
      expect(response).to have_http_status(:not_found)
    end
  end
end
