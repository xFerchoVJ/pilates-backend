require 'swagger_helper'

RSpec.describe 'api/v1/injuries', type: :request do
  let!(:admin) do
    User.create!(
      email: 'admin@injuries.example.com',
      password: 'secret12',
      name: 'Admin',
      last_name: 'User',
      phone: '5550001111',
      role: 'admin',
      gender: 'hombre',
      birthdate: '1990-01-01'
    )
  end

  path '/api/v1/injuries' do
    get('list injuries') do
      tags 'Injuries'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :search, in: :query, schema: { type: :string }
      parameter name: :user_id, in: :query, schema: { type: :integer }
      parameter name: :severity, in: :query, schema: { type: :string, enum: %w[leve moderada grave] }
      parameter name: :recovered, in: :query, schema: { type: :boolean }
      parameter name: :date_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :date_to, in: :query, schema: { type: :string, format: :date }

      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'user@injuries.example.com',
            password: 'secret12',
            name: 'Luis',
            last_name: 'Perez',
            phone: '5551234567',
            role: 'user',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end
        let!(:inj1) { Injury.create!(user: user, injury_type: 'Rodilla', description: 'Dolor leve', severity: 'leve', date_ocurred: Date.today, recovered: false) }
        let!(:inj2) { Injury.create!(user: user, injury_type: 'Espalda', description: 'Dolor moderado', severity: 'moderada', date_ocurred: Date.today - 1, recovered: true) }

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

    post('create injury') do
      tags 'Injuries'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :injury, in: :body, required: true, schema: {
        type: :object,
        properties: {
          injury: {
            type: :object,
            properties: {
              user_id: { type: :integer },
              injury_type: { type: :string },
              description: { type: :string },
              severity: { type: :string, enum: %w[leve moderada grave] },
              date_ocurred: { type: :string, format: :date },
              recovered: { type: :boolean }
            },
            required: %i[user_id injury_type recovered]
          }
        }
      }

      response(201, 'created') do
        let!(:user) do
          User.create!(
            email: 'user2@injuries.example.com',
            password: 'secret12',
            name: 'Ana',
            last_name: 'Lopez',
            phone: '5559876543',
            role: 'user',
            gender: 'mujer',
            birthdate: '1992-02-02'
          )
        end

        let(:injury) do
          {
            user_id: user.id,
            injury_type: 'Hombro',
            description: 'Molestia',
            severity: 'leve',
            date_ocurred: Date.today.iso8601,
            recovered: false
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

  path '/api/v1/injuries/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'injury id'

    get('show injury') do
      tags 'Injuries'
      produces 'application/json'
      security [ bearerAuth: [] ]
      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'user3@injuries.example.com',
            password: 'secret12',
            name: 'Jose',
            last_name: 'Gomez',
            phone: '5551112222',
            role: 'user',
            gender: 'hombre',
            birthdate: '1989-03-03'
          )
        end
        let!(:record) { Injury.create!(user: user, injury_type: 'Tobillo', description: 'Golpe', severity: 'leve', date_ocurred: Date.today, recovered: false) }
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

    patch('update injury') do
      tags 'Injuries'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :injury, in: :body, schema: {
        type: :object,
        properties: {
          injury: {
            type: :object,
            properties: {
              description: { type: :string },
              recovered: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'user4@injuries.example.com',
            password: 'secret12',
            name: 'Mar',
            last_name: 'Diaz',
            phone: '5553334444',
            role: 'user',
            gender: 'mujer',
            birthdate: '1991-04-04'
          )
        end
        let!(:record) { Injury.create!(user: user, injury_type: 'Cuello', description: 'Rigidez', severity: 'moderada', date_ocurred: Date.today, recovered: false) }
        let(:id) { record.id }
        let(:injury) { { description: 'Mejorando', recovered: true } }

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

    delete('delete injury') do
      tags 'Injuries'
      security [ bearerAuth: [] ]

      response(204, 'no content') do
        let!(:user) do
          User.create!(
            email: 'user5@injuries.example.com',
            password: 'secret12',
            name: 'Rafa',
            last_name: 'Nadal',
            phone: '5555556666',
            role: 'user',
            gender: 'hombre',
            birthdate: '1986-06-03'
          )
        end
        let!(:record) { Injury.create!(user: user, injury_type: 'Hombro', description: 'Antigua', severity: 'leve', date_ocurred: Date.today - 10, recovered: true) }
        let(:id) { record.id }

        run_test!
      end
    end
  end

  path '/api/v1/injuries/injuries_by_user' do
    get('injuries_by_user injuries') do
      tags 'Injuries'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :user_id, in: :query, schema: { type: :integer }, required: true

      response(200, 'successful') do
        let!(:instructor) do
          User.create!(
            email: 'inst@injuries.example.com',
            password: 'secret12',
            name: 'Inst',
            last_name: 'Ructor',
            phone: '5552223333',
            role: 'instructor',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end

        let!(:patient) do
          User.create!(
            email: 'patient@injuries.example.com',
            password: 'secret12',
            name: 'Pat',
            last_name: 'Ient',
            phone: '5550002222',
            role: 'user',
            gender: 'hombre',
            birthdate: '1995-05-05'
          )
        end
        let!(:inj) { Injury.create!(user: patient, injury_type: 'Espalda', description: 'Molestia', severity: 'leve', date_ocurred: Date.today, recovered: false) }
        let(:user_id) { patient.id }

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
