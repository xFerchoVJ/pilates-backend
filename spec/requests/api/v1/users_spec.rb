require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  let!(:admin) do
    User.create!(
      email: 'admin@users.example.com',
      password: 'secret12',
      name: 'Admin',
      last_name: 'User',
      phone: '5550001111',
      role: 'admin',
      gender: 'hombre',
      birthdate: '1990-01-01'
    )
  end

  path '/api/v1/users' do
    get('list users') do
      tags 'Users'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :search, in: :query, schema: { type: :string }
      parameter name: :role, in: :query, schema: { type: :string, enum: %w[user instructor admin] }
      parameter name: :gender, in: :query, schema: { type: :string, enum: %w[hombre mujer otro] }
      parameter name: :date_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :date_to, in: :query, schema: { type: :string, format: :date }
      parameter name: :has_injuries, in: :query, schema: { type: :string, enum: %w[pending yes no] }

      response(200, 'successful') do
        let!(:u1) do
          User.create!(email: 'u1@users.example.com', password: 'secret12', name: 'U1', last_name: 'One', phone: '5551234567', role: 'user', gender: 'hombre', birthdate: '1990-01-01')
        end
        let!(:u2) do
          User.create!(email: 'u2@users.example.com', password: 'secret12', name: 'U2', last_name: 'Two', phone: '5559876543', role: 'instructor', gender: 'mujer', birthdate: '1992-02-02')
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

    post('create user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :user, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, minLength: 6 },
              name: { type: :string },
              last_name: { type: :string },
              phone: { type: :string },
              role: { type: :string, enum: %w[user instructor admin] },
              gender: { type: :string, enum: %w[hombre mujer otro] },
              birthdate: { type: :string, format: :date },
              required: %i[email password name last_name phone role gender birthdate]
            }
          }
        }
      }

      response(201, 'created') do
        let(:user) do
          {
            email: 'created@users.example.com',
            password: 'secret12',
            name: 'Created',
            last_name: 'User',
            phone: '5555554444',
            role: 'user',
            gender: 'hombre',
            birthdate: '1993-03-03'
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

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'user id'

    get('show user') do
      tags 'Users'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let!(:user_record) do
          User.create!(email: 'show@users.example.com', password: 'secret12', name: 'Show', last_name: 'User', phone: '5550003333', role: 'user', gender: 'hombre', birthdate: '1990-01-01')
        end
        let(:id) { user_record.id }

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

    patch('update user') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              last_name: { type: :string },
              phone: { type: :string },
              gender: { type: :string, enum: %w[hombre mujer otro] },
              birthdate: { type: :string, format: :date },
              has_injuries: { type: :string, enum: %w[pending yes no] },
              profile_picture: { type: :file }
            }
          }
        }
      }

      response(200, 'successful') do
        let!(:user_record) do
          User.create!(email: 'update@users.example.com', password: 'secret12', name: 'Upd', last_name: 'User', phone: '5552224444', role: 'user', gender: 'hombre', birthdate: '1990-01-01')
        end
        let(:id) { user_record.id }
        let(:user) { { name: 'Updated' } }

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

    delete('delete user') do
      tags 'Users'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let!(:user_record) do
          User.create!(email: 'delete@users.example.com', password: 'secret12', name: 'Del', last_name: 'User', phone: '5553337777', role: 'user', gender: 'hombre', birthdate: '1990-01-01')
        end
        let(:id) { user_record.id }

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

  # Password reset flows
  path '/api/v1/users/send_password_reset' do
    post('send_password_reset users') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :email, in: :query, type: :string, required: true

      response(200, 'successful') do
        let!(:user) do
          User.create!(email: 'reset@users.example.com', password: 'secret12', name: 'Reset', last_name: 'User', phone: '5551119999', role: 'user', gender: 'hombre', birthdate: '1990-01-01')
        end
        let(:email) { 'reset@users.example.com' }

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

  path '/api/v1/users/reset_password' do
    patch('reset_password users') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :reset_password_token, in: :query, type: :string, required: true
      parameter name: :password, in: :query, type: :string, required: true

      response(200, 'successful') do
        let!(:user) do
          User.create!(email: 'reset2@users.example.com', password: 'secret12', name: 'Reset2', last_name: 'User', phone: '5558882222', role: 'user', gender: 'hombre', birthdate: '1990-01-01')
        end
        before { user.update!(reset_password_token: 'ABC123', reset_password_sent_at: Time.current) }
        let(:reset_password_token) { 'ABC123' }
        let(:password) { 'newsecret12' }

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

  path '/api/v1/users/validate_password_reset_token' do
    post('validate_password_reset_token users') do
      tags 'Users'
      produces 'application/json'
      parameter name: :reset_password_token, in: :query, type: :string, required: true

      response(200, 'successful') do
        let!(:user) do
          User.create!(email: 'reset3@users.example.com', password: 'secret12', name: 'Reset3', last_name: 'User', phone: '5557773333', role: 'user', gender: 'hombre', birthdate: '1990-01-01')
        end
        before { user.update!(reset_password_token: 'XYZ999', reset_password_sent_at: Time.current) }
        let(:reset_password_token) { 'XYZ999' }

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
