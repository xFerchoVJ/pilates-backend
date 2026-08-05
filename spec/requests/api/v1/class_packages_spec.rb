require 'rails_helper'
RSpec.describe "Api::V1::ClassPackages", type: :request do
  let!(:admin) { create(:user, role: 'admin') }
  let!(:user) { create(:user, role: 'user') }
  let!(:auth_headers_admin) { { 'Authorization' => "Bearer #{JwtService.encode({ sub: admin.id, role: admin.role }, exp: JwtService.access_exp.from_now)}" } }
  let!(:auth_headers_user) { { 'Authorization' => "Bearer #{JwtService.encode({ sub: user.id, role: user.role }, exp: JwtService.access_exp.from_now)}" } }
  let!(:class_package) { create(:class_package, name: "Unique Package #{SecureRandom.hex(4)}", status: true) }

  describe "GET /index" do
   it "allows admin to see all class packages" do
    inactive_class_package = create(:class_package, status: false)
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id, inactive_class_package.id)
   end

   it "allows user to see active class packages only" do
    inactive_class_package = create(:class_package, status: false)
    get '/api/v1/class_packages', headers: auth_headers_user, params: { per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
    expect(ids).not_to include(inactive_class_package.id)
   end

   it "allows non-authenticated users to see active class packages" do
    inactive_class_package = create(:class_package, status: false)
    get '/api/v1/class_packages', params: { per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
    expect(ids).not_to include(inactive_class_package.id)
   end

   it "does not expose inactive class packages to non-authenticated users" do
    inactive_class_package = create(:class_package, status: false)
    get '/api/v1/class_packages', params: { status: false, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).not_to include(inactive_class_package.id)
   end

   # test filters
   it "filters by search" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { search: class_package.name, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by status" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { status: class_package.status, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by currency" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { currency: class_package.currency, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by price min" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { price_min: class_package.price, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by price max" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { price_max: class_package.price, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by class_count min" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { class_count_min: class_package.class_count, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by class_count max" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { class_count_max: class_package.class_count, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by created_from" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { created_from: class_package.created_at, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end

   it "filters by created_to" do
    get '/api/v1/class_packages', headers: auth_headers_admin, params: { created_to: class_package.created_at, per_page: 100 }
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)
    expect(data['class_packages']).to be_an(Array)
    ids = data['class_packages'].map { |package| package['id'] }
    expect(ids).to include(class_package.id)
   end
  end

  describe "GET /show" do
    it "allows admin to see a class package" do
      get "/api/v1/class_packages/#{class_package.id}", headers: auth_headers_admin
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['id']).to eq(class_package.id)
    end

    it "allows user to see a class package" do
      get "/api/v1/class_packages/#{class_package.id}", headers: auth_headers_user
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['id']).to eq(class_package.id)
    end

    it "does not expose inactive class packages to users" do
      inactive_class_package = create(:class_package, status: false)
      get "/api/v1/class_packages/#{inactive_class_package.id}", headers: auth_headers_user
      expect(response).to have_http_status(:not_found)
    end

    it "allows non-authenticated users to see an active class package" do
      get "/api/v1/class_packages/#{class_package.id}"
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['id']).to eq(class_package.id)
    end

    it "does not expose inactive class packages to non-authenticated users" do
      inactive_class_package = create(:class_package, status: false)
      get "/api/v1/class_packages/#{inactive_class_package.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    it "allows admin to create a new class package" do
      post "/api/v1/class_packages", params: { class_package: { name: 'Test Package', description: 'Test Description', class_count: 10, price: 100, currency: 'MXN', status: true } }, headers: auth_headers_admin
      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data['name']).to eq('Test Package')
    end

    it "forbids for non-admin users" do
      post "/api/v1/class_packages", params: { class_package: { name: 'Test Package', description: 'Test Description', class_count: 10, price: 100, currency: 'MXN', status: true } }, headers: auth_headers_user
      expect(response).to have_http_status(:forbidden)
    end

    it "returns validation errors for invalid params" do
      post "/api/v1/class_packages", params: { class_package: { name: nil, description: 'Test Description', class_count: 10, price: 100, currency: 'MXN', status: true } }, headers: auth_headers_admin
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "forbids non-authenticated users" do
      post "/api/v1/class_packages", params: { class_package: { name: 'Test Package', description: 'Test Description', class_count: 10, price: 100, currency: 'MXN', status: true } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /update" do
    it "allows admin to update a class package" do
      put "/api/v1/class_packages/#{class_package.id}", params: { class_package: { name: 'Updated Package', description: 'Updated Description', class_count: 20, price: 200, currency: 'MXN', status: false } }, headers: auth_headers_admin
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['name']).to eq('Updated Package')
    end

    it "forbids for non-admin users" do
      put "/api/v1/class_packages/#{class_package.id}", params: { class_package: { name: 'Updated Package', description: 'Updated Description', class_count: 20, price: 200, currency: 'MXN', status: false } }, headers: auth_headers_user
      expect(response).to have_http_status(:forbidden)
    end

    it "returns validation errors for invalid params" do
      put "/api/v1/class_packages/#{class_package.id}", params: { class_package: { name: nil, description: 'Updated Description', class_count: 20, price: 200, currency: 'MXN', status: false } }, headers: auth_headers_admin
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "forbids non-authenticated users" do
      put "/api/v1/class_packages/#{class_package.id}", params: { class_package: { name: 'Updated Package', description: 'Updated Description', class_count: 20, price: 200, currency: 'MXN', status: false } }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found for non-existent class package" do
      put "/api/v1/class_packages/999999", params: { class_package: { name: 'Updated Package', description: 'Updated Description', class_count: 20, price: 200, currency: 'MXN', status: false } }, headers: auth_headers_admin
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /destroy" do
    it "allows admin to delete a class package" do
      delete "/api/v1/class_packages/#{class_package.id}", headers: auth_headers_admin
      expect(response).to have_http_status(:no_content)
    end

    it "forbids for non-admin users" do
      delete "/api/v1/class_packages/#{class_package.id}", headers: auth_headers_user
      expect(response).to have_http_status(:forbidden)
    end

    it "forbids non-authenticated users" do
      delete "/api/v1/class_packages/#{class_package.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns not found for non-existent class package" do
      delete "/api/v1/class_packages/999999", headers: auth_headers_admin
      expect(response).to have_http_status(:not_found)
    end
  end
end
