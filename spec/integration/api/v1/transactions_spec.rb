require 'swagger_helper'

RSpec.describe 'Api::V1::Transactions', type: :request do
  path '/api/v1/transactions' do
    get('list transactions') do
      tags 'Transactions'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :user_id, in: :query, schema: { type: :integer }
      parameter name: :status, in: :query, schema: { type: :string }
      parameter name: :transaction_type, in: :query, schema: { type: :string }

      response(200, 'successful') do
        let!(:transactions) { create_list(:transaction, 3) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/transactions/{id}' do
    get('show transaction') do
      tags 'Transactions'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :string, description: 'transaction id'

      response(200, 'successful') do
        let!(:transaction) { create(:transaction) }
        let(:id) { transaction.id }

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

