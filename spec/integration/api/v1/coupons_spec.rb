require 'swagger_helper'

RSpec.describe 'Api::V1::Coupons', type: :request do
  path '/api/v1/coupons' do
    get("list coupons") do
      tags "Coupons"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :search, in: :query, schema: { type: :string }
      parameter name: :only_new_users, in: :query, schema: { type: :boolean }
      parameter name: :active_now, in: :query, schema: { type: :boolean }

      response(200, "successful") do
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end

    post("create coupon") do
      tags "Coupons"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :coupon, in: :body, required: true, schema: {
        type: :object,
        properties: {
          coupon: {
            type: :object,
            properties: {
              code: { type: :string },
              discount_type: { type: :string, enum: %w[percentage fixed] },
              discount_value: { type: :integer },
              usage_limit: { type: :integer },
              usage_limit_per_user: { type: :integer },
              only_new_users: { type: :boolean },
              active: { type: :boolean },
              starts_at: { type: :string, format: :date },
              ends_at: { type: :string, format: :date },
              metadata: { type: :object }
            },
            required: %i[code discount_type discount_value usage_limit usage_limit_per_user only_new_users active starts_at ends_at metadata]
          }
        }
      }

      response(201, "created") do
        let!(:coupon) { build(:coupon) }
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/coupons/{id}' do
    get("show coupon") do
      tags "Coupons"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :string, description: "coupon id"
      response(200, "successful") do
        let!(:coupon) { create(:coupon) }
        let(:id) { coupon.id }
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end

    patch("update coupon") do
      tags "Coupons"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :coupon, in: :body, required: true, schema: {
        type: :object,
        properties: {
          coupon: {
            type: :object,
            properties: {
              code: { type: :string },
              discount_type: { type: :string, enum: %w[percentage fixed] },
              discount_value: { type: :integer },
              usage_limit: { type: :integer },
              usage_limit_per_user: { type: :integer },
              only_new_users: { type: :boolean },
              active: { type: :boolean },
              starts_at: { type: :string, format: :date },
              ends_at: { type: :string, format: :date },
              metadata: { type: :object }
            }
          }
        }
      }

      response(200, "successful") do
        let!(:coupon) { create(:coupon) }
        let(:id) { coupon.id }
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end

    delete("destroy coupon") do
      tags "Coupons"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :string, description: "coupon id"
      response(204, "no content") do
        let!(:coupon) { create(:coupon) }
        let(:id) { coupon.id }
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/coupons/validate' do
    post("validate coupon") do
      tags "Coupons"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :coupon_code, in: :query, type: :string, description: "coupon code"
      parameter name: :price_cents, in: :query, type: :integer, description: "price cents"

      response(200, "successful") do
        let!(:coupon) { create(:coupon) }
        let(:coupon_code) { coupon.code }
        let(:price_cents) { 1000 }
        after do |example|
          example.metadata[:response][:content] = {
            "application/json" => { example: JSON.parse(response.body, symbolize_names: true) }
          }
        end
        run_test!
      end
    end
  end
end
