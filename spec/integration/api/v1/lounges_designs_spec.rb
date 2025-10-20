require 'swagger_helper'

RSpec.describe 'Api::V1::LoungesDesigns', type: :request do
  path '/api/v1/lounges_designs' do
    get('list lounges_designs') do
      tags 'LoungesDesigns'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let!(:lounges_designs) { create_list(:lounges_design, 3) }

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

    post('create lounge_design') do
      tags 'LoungesDesigns'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :lounge_design, in: :body, required: true, schema: {
        type: :object,
        properties: {
          lounge_design: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              layout_json: {
                 type: :object,
                properties: {
                  spaces: {
                    type: :array, items: {
                      type: :object,
                      properties: {
                        label: { type: :string },
                        x: { type: :integer },
                        y: { type: :integer }
                      }
                    }
                  }
                },
                required: %i[spaces]
              }
            },
            required: %i[name description layout_json]
          }
        }
      }

      response(201, 'created') do
        let(:lounge_design) { build(:lounges_design) }

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

  path '/api/v1/lounges_designs/{id}' do
    get('show lounge_design') do
      tags 'LoungesDesigns'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'lounge_design id'
      response(200, 'successful') do
        let!(:lounge_design) { create(:lounges_design) }
        let(:id) { lounge_design.id }

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

    patch('update lounge_design') do
      tags 'LoungesDesigns'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'lounge_design id'
      parameter name: :lounge_design, in: :body, required: true, schema: {
        type: :object,
        properties: {
          lounge_design: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              layout_json: {
                type: :object,
                properties: {
                  spaces: { type: :array, items: { type: :object, properties: { label: { type: :string }, x: { type: :integer }, y: { type: :integer } } } }
                }
              }
            }
          }
        }
      }

      response(200, 'successful') do
        let!(:lounge_design) { create(:lounges_design) }
        let(:id) { lounge_design.id }
        let(:lounge_design) { { name: 'Updated Name', description: 'Updated Description', layout_json: { spaces: [ { label: 'Updated Label', x: 1, y: 1 } ] } } }

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

    delete('delete lounge_design') do
      tags 'LoungesDesigns'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :string, description: 'lounge_design id'
      response(204, 'no content') do
        let!(:lounge_design) { create(:lounges_design) }
        let(:id) { lounge_design.id }

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
