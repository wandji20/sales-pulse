require 'rails_helper'

RSpec.describe "Products", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/products/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/products/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/products/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
