require 'swagger_helper'

RSpec.describe 'Api::V1::UserClassPackages', type: :request do
  path '/api/v1/user_class_packages' do
    get('list user_class_packages') do
      tags 'UserClassPackages'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :user_id, in: :query, schema: { type: :integer }
      parameter name: :class_package_id, in: :query, schema: { type: :integer }
      parameter name: :status, in: :query, schema: { type: :string }
      parameter name: :remaining_classes_min, in: :query, schema: { type: :integer }
      parameter name: :remaining_classes_max, in: :query, schema: { type: :integer }
      parameter name: :purchased_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :purchased_to, in: :query, schema: { type: :string, format: :date }
      parameter name: :date_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :date_to, in: :query, schema: { type: :string, format: :date }

      response(200, 'successful') do
        let!(:user_class_packages) { create_list(:user_class_package, 3) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/user_class_packages/{id}' do
    get('show user_class_package') do
      tags 'UserClassPackages'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :string, description: 'user_class_package id'

      response(200, 'successful') do
        let!(:user_class_package) { create(:user_class_package) }
        let(:id) { user_class_package.id }

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

