require 'swagger_helper'

RSpec.describe 'api/v1/lounges', type: :request do
  let!(:admin) do
    User.create!(
      email: 'admin@lounges.example.com',
      password: 'secret12',
      name: 'Admin',
      last_name: 'User',
      phone: '5550001111',
      role: 'admin',
      gender: 'hombre',
      birthdate: '1990-01-01'
    )
  end

  path '/api/v1/lounges' do
    get('list lounges') do
      tags 'Lounges'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :search, in: :query, schema: { type: :string }
      parameter name: :lounge_design_id, in: :query, schema: { type: :integer }
      parameter name: :date_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :date_to, in: :query, schema: { type: :string, format: :date }

      response(200, 'successful') do
        let!(:design) { LoungeDesign.create!(name: 'Layout L', layout_json: { 'spaces' => [ { 'label' => 'L1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:l1) { Lounge.create!(name: 'Sala L1', description: 'Desc 1', lounge_design: design) }
        let!(:l2) { Lounge.create!(name: 'Sala L2', description: 'Desc 2', lounge_design: design) }

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

    post('create lounge') do
      tags 'Lounges'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :lounge, in: :body, required: true, schema: {
        type: :object,
        properties: {
          lounge: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              lounge_design_id: { type: :integer }
            },
            required: %i[name description lounge_design_id]
          }
        }
      }

      response(201, 'created') do
        let!(:design) { LoungeDesign.create!(name: 'Layout NL', layout_json: { 'spaces' => [ { 'label' => 'N1', 'x' => 0, 'y' => 0 } ] }) }

        let(:lounge) do
          {
            name: 'Nueva Sala',
            description: 'Sala nueva',
            lounge_design_id: design.id
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

  path '/api/v1/lounges/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'lounge id'

    get('show lounge') do
      tags 'Lounges'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let!(:design) { LoungeDesign.create!(name: 'Layout SL', layout_json: { 'spaces' => [ { 'label' => 'S1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:record) { Lounge.create!(name: 'Sala Show', description: 'Detalle', lounge_design: design) }
        let(:id) { record.id }

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

    patch('update lounge') do
      tags 'Lounges'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :lounge, in: :body, schema: {
        type: :object,
        properties: {
          lounge: {
            type: :object,
            properties: {
              description: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let!(:design) { LoungeDesign.create!(name: 'Layout UL', layout_json: { 'spaces' => [ { 'label' => 'U1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:record) { Lounge.create!(name: 'Sala Update', description: 'Desc old', lounge_design: design) }
        let(:id) { record.id }
        let(:lounge) { { description: 'Desc nueva' } }

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

    delete('delete lounge') do
      tags 'Lounges'
      security [ bearerAuth: [] ]

      response(204, 'no content') do
        let!(:design) { LoungeDesign.create!(name: 'Layout DL', layout_json: { 'spaces' => [ { 'label' => 'D1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:record) { Lounge.create!(name: 'Sala Delete', description: 'Desc', lounge_design: design) }
        let(:id) { record.id }

        run_test!
      end
    end
  end
end
