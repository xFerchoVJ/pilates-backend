require 'swagger_helper'

RSpec.describe 'Api::V1::Devices', type: :request do
  path '/api/v1/devices' do
    get('list devices') do
      tags 'Devices'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let!(:devices) { create_list(:device, 3) }

        after do |example|
          example.metadata[:response][:content] = { 'application/json' => { example: JSON.parse(response.body, symbolize_names: true) } }
        end
        run_test!
      end
    end

    post('create device') do
      tags 'Devices'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :device, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer },
          expo_push_token: { type: :string }
        },
        required: %i[user_id expo_push_token]
      }

      response(201, 'created') do
        let!(:user) { create(:user) }
        let!(:device) { create(:device, user: user) }

        after do |example|
          example.metadata[:response][:content] = { 'application/json' => { example: JSON.parse(response.body, symbolize_names: true) } }
        end
        run_test!
      end
    end
  end

  path '/api/v1/devices/{id}' do
    get('show device') do
      tags 'Devices'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'device id'

      response(200, 'successful') do
        let!(:device) { create(:device) }
        let(:id) { device.id }
        after do |example|
          example.metadata[:response][:content] = { 'application/json' => { example: JSON.parse(response.body, symbolize_names: true) } }
        end
        run_test!
      end
    end


    patch('update device') do
      tags 'Devices'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'device id'
      parameter name: :device, in: :body, required: true, schema: {
        type: :object,
        properties: {
          device: { type: :object, properties: { expo_push_token: { type: :string } } }
        },
        required: %i[device]
      }

      response(200, 'successful') do
        let!(:device) { create(:device) }
        let(:id) { device.id }
        let(:device) { { device: { expo_push_token: 'new_expo_push_token' } } }

        after do |example|
          example.metadata[:response][:content] = { 'application/json' => { example: JSON.parse(response.body, symbolize_names: true) } }
        end
        run_test!
      end
    end

    delete('destroy device') do
      tags 'Devices'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'device id'
      response(204, 'no content') do
        let!(:device) { create(:device) }
        let(:id) { device.id }
        after do |example|
          example.metadata[:response][:content] = { 'application/json' => { example: JSON.parse(response.body, symbolize_names: true) } }
        end
        run_test!
      end
    end
  end
end
