require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #create" do
    xit "returns http success" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      #allow_any_instance_of(Users::RegistrationsController).to receive(:create).and_return('sfsdf')
      get :create
      db_mgr=Util::UserDbManager.new({:load_event=>'stub'})
      expect(assigns(:db_mgr)).to eq(db_mgr)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    context "when registration is enabled" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("DISABLE_USER_REGISTRATION").and_return("false")
      end

      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context "when registration is disabled" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("DISABLE_USER_REGISTRATION").and_return("true")
      end

      it "redirects to root path with flash message" do
        get :new
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("User registration is currently disabled. Please try again later.")
      end
    end
  end
end
