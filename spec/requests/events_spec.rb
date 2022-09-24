require 'rails_helper'

RSpec.describe "Events", type: :request do

    describe "GET /events" do
      it "renders the Events index page" do
        get events_path
        expect(response).to render_template(:index)
      end
    end

    describe "GET /events" do
      it "renders the Events show page" do
        test_event = FactoryBot.create(:event)
        get event_path(id: test_event.id)
        expect(response).to render_template(:show)
      end
      it "redirects to the Events index page if the Event ID is invalid" do
        get event_path(id: 5000) # an ID that doesn't exist
        expect(response).to redirect_to events_path
      end
    end

end    