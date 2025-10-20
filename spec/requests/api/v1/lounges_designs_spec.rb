require 'rails_helper'

RSpec.describe "Api::V1::LoungesDesigns", type: :request do
  let!(:admin) { create(:user, role: 'admin') }
  let!(:user) { create(:user, role: 'user') }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{JwtService.encode({ sub: admin.id, role: admin.role }, exp: JwtService.access_exp.from_now)}" } }
  let!(:invalid_auth_headers) { { 'Authorization' => "Bearer #{JwtService.encode({ sub: user.id, role: user.role }, exp: JwtService.access_exp.from_now)}" } }
  let!(:lounge_design) { create(:lounge_design) }

  describe "GET /api/v1/lounges_designs" do
    it 'allows admin to see all lounge designs' do
      get '/api/v1/lounges_designs', headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it 'forbids for non-admin users' do
      get '/api/v1/lounges_designs', headers: invalid_auth_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/lounges_designs" do
    let!(:valid_params) { { lounge_design: { name: 'Layout 1', layout_json: { 'spaces' => [ { 'label' => '1', 'x' => 0, 'y' => 0 } ] } } } }
    let!(:invalid_params) { { lounge_design: { name: nil, layout_json: { 'spaces' => [ { 'label' => '1', 'x' => 0, 'y' => 0 } ] } } } }

    it 'allows admin to create a new lounge design' do
      post '/api/v1/lounges_designs', params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["name"]).to eq('Layout 1')
    end

    it 'forbids for non-admin users' do
      post '/api/v1/lounges_designs', params: valid_params, headers: invalid_auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns validation errors for invalid params' do
      post '/api/v1/lounges_designs', params: invalid_params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /api/v1/lounges_designs/:id' do
    it 'allows admin to see a lounge design' do
      get "/api/v1/lounges_designs/#{lounge_design.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq(lounge_design.name)
    end

    it 'forbids for non-admin users' do
      get "/api/v1/lounges_designs/#{lounge_design.id}", headers: invalid_auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns not found for non-existent lounge design' do
      get "/api/v1/lounges_designs/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/v1/lounges_designs/:id' do
    let!(:valid_params) { { lounge_design: { name: 'Layout 2', layout_json: { 'spaces' => [ { 'label' => '2', 'x' => 0, 'y' => 0 } ] } } } }
    let!(:invalid_params) { { lounge_design: { name: nil, layout_json: { 'spaces' => [ { 'label' => '2', 'x' => 0, 'y' => 0 } ] } } } }

    it 'allows admin to update a lounge design' do
      patch "/api/v1/lounges_designs/#{lounge_design.id}", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq('Layout 2')
    end

    it 'forbids for non-admin users' do
      patch "/api/v1/lounges_designs/#{lounge_design.id}", params: valid_params, headers: invalid_auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns validation errors for invalid params' do
      patch "/api/v1/lounges_designs/#{lounge_design.id}", params: invalid_params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns not found for non-existent lounge design' do
      patch "/api/v1/lounges_designs/999999", params: { lounge_design: { name: 'Layout 2', layout_json: { 'spaces' => [ { 'label' => '2', 'x' => 0, 'y' => 0 } ] } } }, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/lounges_designs/:id' do
    it 'allows admin to delete a lounge design' do
      delete "/api/v1/lounges_designs/#{lounge_design.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
    end

    it 'forbids for non-admin users' do
      delete "/api/v1/lounges_designs/#{lounge_design.id}", headers: invalid_auth_headers
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns not found for non-existent lounge design' do
      delete "/api/v1/lounges_designs/999999", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
