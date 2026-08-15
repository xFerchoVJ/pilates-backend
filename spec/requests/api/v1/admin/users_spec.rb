require 'rails_helper'

RSpec.describe 'api/v1/admin/users', type: :request do
  let(:admin) { create(:user, role: :admin, password: 'secret12') }
  let(:regular_user) { create(:user, role: :user, password: 'secret12') }

  def auth_headers_for(user)
    token = JwtService.encode({ sub: user.id, role: user.role }, exp: JwtService.access_exp.from_now)
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /api/v1/admin/users/birthdays' do
    it 'returns user and instructor birthdays for the requested month ordered by day' do
      user_birthday = create(:user, role: :user, name: 'Beta', birthdate: Date.new(1992, 8, 20))
      instructor_birthday = create(:user, role: :instructor, name: 'Alpha', birthdate: Date.new(1988, 8, 5))
      create(:user, role: :admin, birthdate: Date.new(1980, 8, 10))
      create(:user, role: :user, birthdate: Date.new(1990, 9, 5))
      create(:user, role: :instructor, birthdate: nil)

      get '/api/v1/admin/users/birthdays', params: { month: 8 }, headers: auth_headers_for(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['month']).to eq(8)
      expect(body['birthdays'].map { |birthday| birthday['id'] }).to eq([ instructor_birthday.id, user_birthday.id ])
      expect(body['birthdays'].map { |birthday| birthday['role'] }).to contain_exactly('instructor', 'user')
    end

    it 'defaults to the current month when month is omitted' do
      today = Time.zone.today
      birthday = create(:user, role: :user, birthdate: Date.new(1990, today.month, 1))
      create(:user, role: :user, birthdate: Date.new(1990, today.next_month.month, 1))

      get '/api/v1/admin/users/birthdays', headers: auth_headers_for(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['month']).to eq(today.month)
      expect(body['birthdays'].map { |item| item['id'] }).to eq([ birthday.id ])
    end

    it 'forbids non-admin users' do
      get '/api/v1/admin/users/birthdays', params: { month: 8 }, headers: auth_headers_for(regular_user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects invalid months' do
      get '/api/v1/admin/users/birthdays', params: { month: 13 }, headers: auth_headers_for(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/admin/users/:id/password' do
    it 'lets admins change a regular user password' do
      target_user = create(:user, role: :user, password: 'secret12')

      patch "/api/v1/admin/users/#{target_user.id}/password",
            params: { password: 'newsecret12' },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:ok)
      expect(target_user.reload.authenticate('newsecret12')).to be_truthy
    end

    it 'lets admins change an instructor password' do
      instructor = create(:user, role: :instructor, password: 'secret12')

      patch "/api/v1/admin/users/#{instructor.id}/password",
            params: { user: { password: 'newsecret12' } },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:ok)
      expect(instructor.reload.authenticate('newsecret12')).to be_truthy
    end

    it 'forbids changing another admin password' do
      other_admin = create(:user, role: :admin, password: 'secret12')

      patch "/api/v1/admin/users/#{other_admin.id}/password",
            params: { password: 'newsecret12' },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:forbidden)
      expect(other_admin.reload.authenticate('secret12')).to be_truthy
    end

    it 'forbids admins changing their own password through this endpoint' do
      patch "/api/v1/admin/users/#{admin.id}/password",
            params: { password: 'newsecret12' },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:forbidden)
      expect(admin.reload.authenticate('secret12')).to be_truthy
    end

    it 'forbids non-admin users' do
      target_user = create(:user, role: :user, password: 'secret12')

      patch "/api/v1/admin/users/#{target_user.id}/password",
            params: { password: 'newsecret12' },
            headers: auth_headers_for(regular_user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects invalid passwords' do
      target_user = create(:user, role: :user, password: 'secret12')

      patch "/api/v1/admin/users/#{target_user.id}/password",
            params: { password: 'short' },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(target_user.reload.authenticate('secret12')).to be_truthy
    end
  end

  describe 'PATCH /api/v1/users/:id password restrictions' do
    it 'prevents admins from changing regular user passwords through the generic update endpoint' do
      target_user = create(:user, role: :user, password: 'secret12')

      patch "/api/v1/users/#{target_user.id}",
            params: { user: { password: 'newsecret12' } },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:forbidden)
      expect(target_user.reload.authenticate('secret12')).to be_truthy
    end

    it 'prevents admins from changing another admin password through the generic update endpoint' do
      other_admin = create(:user, role: :admin, password: 'secret12')

      patch "/api/v1/users/#{other_admin.id}",
            params: { user: { password: 'newsecret12' } },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:forbidden)
      expect(other_admin.reload.authenticate('secret12')).to be_truthy
    end

    it 'prevents admins from changing their own password through the generic update endpoint' do
      patch "/api/v1/users/#{admin.id}",
            params: { user: { password: 'newsecret12' } },
            headers: auth_headers_for(admin)

      expect(response).to have_http_status(:forbidden)
      expect(admin.reload.authenticate('secret12')).to be_truthy
    end
  end
end
