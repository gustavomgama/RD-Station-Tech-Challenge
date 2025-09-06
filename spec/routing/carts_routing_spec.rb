require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe "routing" do
    describe "GET /cart" do
      it "routes to #show" do
        expect(get: "/cart").to route_to("carts#show")
      end
    end

    describe "POST /cart" do
      it "routes to #create" do
        expect(post: "/cart").to route_to("carts#create")
      end
    end

    describe "POST /cart/add_item" do
      it "routes to #update" do
        expect(post: "/cart/add_item").to route_to("carts#update")
      end
    end

    describe "DELETE /cart/:product_id" do
      it "routes to #destroy" do
        expect(delete: "/cart/1").to route_to("carts#destroy", product_id: "1")
      end
    end
  end
end
