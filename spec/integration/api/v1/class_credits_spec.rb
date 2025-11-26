require 'swagger_helper'

RSpec.describe 'Api::V1::ClassCredits', type: :request do
  path '/api/v1/class_credits' do
    get('list class_credits') do
      tags 'ClassCredits'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :page, in: :query, type: :integer, description: 'page number'
      parameter name: :per_page, in: :query, type: :integer, description: 'number of items per page'
      parameter name: :user_id, in: :query, type: :string, description: 'user id'
      parameter name: :reservation_id, in: :query, type: :string, description: 'reservation id'
      parameter name: :status, in: :query, type: :string, description: 'status'
      parameter name: :used_from, in: :query, type: :string, description: 'used from'
      parameter name: :used_to, in: :query, type: :string, description: 'used to'

      response(200, 'successful') do
        let!(:class_credits) { create_list(:class_credit, 3) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end

    post('create class_credit') do
      tags 'ClassCredits'
      produces 'application/json'
      consumes 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :class_credit, in: :body, required: true, schema: {
        type: :object,
        properties: {
          user_id: { type: :string },
          reservation_id: { type: :string },
          status: { type: :string, default: "unused" },
          used_at: { type: :string }
        },
        required: %i[ user_id ]
      }

      response(200, 'successful') do
        let(:class_credit) { create(:class_credit) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/class_credits/{id}' do
    get('show class_credit') do
      tags 'ClassCredits'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'class_credit id'

      response(200, 'successful') do
        let!(:class_credit) { create(:class_credit) }
        let(:id) { class_credit.id }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end
end
