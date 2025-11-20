require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  # Common helpers
  let(:json_headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  path '/api/v1/signup' do
    post('signup auth') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string, minLength: 6 },
          name: { type: :string },
          last_name: { type: :string },
          phone: { type: :string },
          role: { type: :string, enum: %w[user instructor admin] },
          gender: { type: :string, enum: %w[hombre mujer otro] },
          birthdate: { type: :string, format: :date }
        },
        required: %i[email password name last_name phone role gender birthdate]
      }

      response(201, 'created') do
        let(:user) do
          {
            email: 'new_user@example.com',
            password: 'secret12',
            name: 'New',
            last_name: 'User',
            phone: '5551234567',
            role: 'user',
            gender: 'hombre',
            birthdate: '1990-01-01'
          }
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/login' do
    post('login auth') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      # Using query parameters here for documentation/testing simplicity.
      # The controller reads from params so this works for tests and docs.
      parameter name: :email, in: :query, type: :string, required: true
      parameter name: :password, in: :query, type: :string, required: true

      response(200, 'successful') do
        let!(:existing_user) do
          User.create!(
            email: 'user1@example.com',
            password: 'secret12',
            name: 'Test',
            last_name: 'User',
            phone: '5551112222',
            role: 'user',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end

        let(:email) { 'user1@example.com' }
        let(:password) { 'secret12' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/google' do
    post('google auth') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id_token, in: :query, type: :string, required: true

      response(200, 'successful') do
        let(:id_token) { 'dummy-google-id-token' }

        before do
          allow(GoogleIdTokenService).to receive(:verify).and_return(
            {
              email: 'google.user@example.com',
              sub: 'google-uid-123',
              given_name: 'GUser',
              family_name: 'Example',
              email_verified: true
            }
          )
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/refresh' do
    post('refresh auth') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :refresh_token, in: :query, type: :string, required: true

      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'refresh.user@example.com',
            password: 'secret12',
            name: 'Refresh',
            last_name: 'User',
            phone: '5553334444',
            role: 'user',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end

        let!(:refresh_record) do
          RefreshTokenUser.create!(
            user: user,
            jti: 'refresh-jti-123',
            user_agent: 'RSpec',
            ip: '127.0.0.1',
            expires_at: 30.days.from_now
          )
        end

        let(:refresh_token) { 'refresh-jti-123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/logout' do
    post('logout auth') do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :Authorization, in: :header, schema: { type: :string }, required: false,
                description: 'Bearer access token (optional)'
      parameter name: :refresh_token, in: :query, type: :string, required: false

      response(200, 'successful') do
        # No auth required for this endpoint
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/logout_all' do
    post('logout_all auth') do
      tags 'Auth'
      produces 'application/json'

      parameter name: :Authorization, in: :header, schema: { type: :string }, required: true,
                description: 'Bearer access token'

      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'logoutall.user@example.com',
            password: 'secret12',
            name: 'Logout',
            last_name: 'All',
            phone: '5557778888',
            role: 'user',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end

        let(:Authorization) do
          token = JwtService.encode({ sub: user.id, role: user.role }, exp: JwtService.access_exp.from_now)
          "Bearer #{token}"
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/cleanup_tokens' do
    post('cleanup_tokens auth') do
      tags 'Auth'
      produces 'application/json'

      parameter name: :Authorization, in: :header, schema: { type: :string }, required: true,
                description: 'Bearer access token (admin only)'

      response(200, 'successful') do
        let!(:admin) do
          User.create!(
            email: 'admin@example.com',
            password: 'secret12',
            name: 'Admin',
            last_name: 'User',
            phone: '5550001111',
            role: 'admin',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end

        let(:Authorization) do
          token = JwtService.encode({ sub: admin.id, role: admin.role }, exp: JwtService.access_exp.from_now)
          "Bearer #{token}"
        end

        before do
          allow(CleanupExpiredTokensJob).to receive(:perform_async).and_return(true)
        end

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/me' do
    get('me auth') do
      tags 'Auth'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let!(:user) { create(:user) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end
end
