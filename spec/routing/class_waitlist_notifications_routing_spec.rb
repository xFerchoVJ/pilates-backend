require "rails_helper"

RSpec.describe ClassWaitlistNotificationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/class_waitlist_notifications").to route_to("class_waitlist_notifications#index")
    end

    it "routes to #show" do
      expect(get: "/class_waitlist_notifications/1").to route_to("class_waitlist_notifications#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/class_waitlist_notifications").to route_to("class_waitlist_notifications#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/class_waitlist_notifications/1").to route_to("class_waitlist_notifications#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/class_waitlist_notifications/1").to route_to("class_waitlist_notifications#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/class_waitlist_notifications/1").to route_to("class_waitlist_notifications#destroy", id: "1")
    end
  end
end
