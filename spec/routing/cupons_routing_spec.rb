require "rails_helper"

RSpec.describe CuponsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cupons").to route_to("cupons#index")
    end

    it "routes to #show" do
      expect(get: "/cupons/1").to route_to("cupons#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/cupons").to route_to("cupons#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/cupons/1").to route_to("cupons#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cupons/1").to route_to("cupons#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cupons/1").to route_to("cupons#destroy", id: "1")
    end
  end
end
