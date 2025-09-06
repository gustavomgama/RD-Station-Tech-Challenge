require "rails_helper"

RSpec.describe CartsController, type: :request do
  let!(:product) { create(:product) }

  def json_response
    JSON.parse(response.body)
  end

  describe "GET #show" do
    context "when cart exists" do
      let!(:cart) { create(:cart) }

      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:session).and_return({ cart_id: cart.id })

        create(:cart_item, cart:, product:, quantity: 2)
        cart.update_total!
      end

      it "returns the cart with products" do
        get cart_path, as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response["id"]).to eq(cart.id)
        expect(json_response["products"].size).to eq(1)
      end
    end

    context "when cart does not exist" do
      it "returns not found error" do
        get cart_path, as: :json

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("Cart not found")
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a cart and adds product" do
        post cart_path, params: { product_id: product.id, quantity: 2 }, as: :json

        expect(response).to have_http_status(:ok)
        expect(session[:cart_id]).to be_present
        expect(json_response["products"].first["quantity"]).to eq(2)
      end
    end

    context "with invalid quantity" do
      it "returns unprocessable entity" do
        post cart_path, params: { product_id: product.id, quantity: 0 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with invalid product" do
      it "returns not found error" do
        post cart_path, params: { product_id: 999, quantity: 1 }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #update" do
    let!(:cart) { create(:cart) }

    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:session).and_return({ cart_id: cart.id })

      create(:cart_item, cart:, product:, quantity: 2)
      cart.update_total!
    end

    it "increments quantity for an existing cart item" do
      post "/cart/add_item", params: { product_id: product.id, quantity: 3 }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response["products"].first["quantity"]).to eq(5)
    end
  end

  describe "DELETE #destroy" do
    let!(:cart) { create(:cart) }
    let!(:cart_item) { create(:cart_item, cart:, product:, quantity: 2) }

    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:session).and_return({ cart_id: cart.id })

      cart.update_total!
    end

    context "when product exists in cart" do
      it "removes the product" do
        delete "/cart/#{cart_item.product.id}", as: :json

        expect(response).to have_http_status(:ok), as: :json
        expect(cart.cart_items.exists?(cart_item.id)).to be false
      end
    end

    context "when product does not exist" do
      it "returns not found error" do
        delete cart_path, params: { product_id: 999 }, as: :json

        expect(response).to have_http_status(:not_found), as: :json
      end
    end
  end
end
