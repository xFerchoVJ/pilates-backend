require 'swagger_helper'

RSpec.describe 'Api::V1::ClassPackages', type: :request do
  path '/api/v1/class_packages' do
    get('list class_packages') do
      tags 'ClassPackages'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :search, in: :query, schema: { type: :string }
      parameter name: :status, in: :query, schema: { type: :boolean }
      parameter name: :currency, in: :query, schema: { type: :string }
      parameter name: :price_min, in: :query, schema: { type: :integer }
      parameter name: :price_max, in: :query, schema: { type: :integer }
      parameter name: :class_count_min, in: :query, schema: { type: :integer }
      parameter name: :class_count_max, in: :query, schema: { type: :integer }
      parameter name: :created_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :created_to, in: :query, schema: { type: :string, format: :date }

      response(200, 'successful') do
        let!(:class_packages) { create_list(:class_package, 3) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end

    post('create class_package') do
      tags 'ClassPackages'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :class_package, in: :body, required: true, schema: {
        type: :object,
        properties: {
          class_package: {
            type: :object,
            properties: { name: { type: :string }, description: { type: :string }, class_count: { type: :integer }, price: { type: :integer }, currency: { type: :string }, status: { type: :boolean } },
            required: %i[name class_count price currency]
          }
        }
      }

      response(201, 'created') do
        let!(:class_package) { build(:class_package) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/class_packages/{id}' do
    get('show class_package') do
      tags 'ClassPackages'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :string, description: 'class_package id'

      response(200, 'successful') do
        let!(:class_package) { create(:class_package) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end

    patch('update class_package') do
      tags 'ClassPackages'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'class_package id'
      parameter name: :class_package, in: :body, required: true, schema: {
        type: :object,
        properties: {
          class_package: {
            type: :object,
            properties: { name: { type: :string }, description: { type: :string }, class_count: { type: :integer }, price: { type: :integer }, currency: { type: :string }, status: { type: :boolean } },
            required: %i[name class_count price currency]
          }
        }
      }

      response(200, 'successful') do
        let!(:class_package) { create(:class_package) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end

    delete('delete class_package') do
      tags 'ClassPackages'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'class_package id'
      response(204, 'no content') do
        let!(:class_package) { create(:class_package) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/class_packages/purchase_with_payment' do
    post('purchase with payment') do
      tags 'ClassPackages'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :class_package_id, in: :body, required: true, schema: {
        type: :object,
        properties: {
          class_package_id: { type: :integer }
        }
      }
      response(200, 'successful') do
        let!(:class_package) { create(:class_package) }

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
