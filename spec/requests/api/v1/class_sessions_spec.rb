require 'swagger_helper'

RSpec.describe 'api/v1/class_sessions', type: :request do
  let!(:admin) do
    User.create!(
      email: 'admin@classsessions.example.com',
      password: 'secret12',
      name: 'Admin',
      last_name: 'User',
      phone: '5550001111',
      role: 'admin',
      gender: 'hombre',
      birthdate: '1990-01-01'
    )
  end


  path '/api/v1/class_sessions' do
    get('list class_sessions') do
      tags 'ClassSessions'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :search, in: :query, schema: { type: :string }
      parameter name: :instructor_id, in: :query, schema: { type: :integer }
      parameter name: :lounge_id, in: :query, schema: { type: :integer }
      parameter name: :date_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :date_to, in: :query, schema: { type: :string, format: :date }
      parameter name: :start_time_from, in: :query, schema: { type: :string }
      parameter name: :start_time_to, in: :query, schema: { type: :string }

      response(200, 'successful') do
        let!(:lounge_design) { LoungeDesign.create!(name: 'Layout A', layout_json: { 'spaces' => [ { 'label' => 'A1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:lounge) { Lounge.create!(name: 'Sala 1', description: 'Sala principal', lounge_design: lounge_design) }
        let!(:instructor) do
          User.create!(
            email: 'instructor@classsessions.example.com',
            password: 'secret12',
            name: 'Inst',
            last_name: 'Ructor',
            phone: '5552223333',
            role: 'instructor',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end
        let!(:cs1) { ClassSession.create!(name: 'Clase 1', description: 'Desc 1', start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour, instructor: instructor, lounge: lounge) }
        let!(:cs2) { ClassSession.create!(name: 'Clase 2', description: 'Desc 2', start_time: 2.days.from_now, end_time: 2.days.from_now + 1.hour, instructor: instructor, lounge: lounge) }

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

    post('create class_session') do
      tags 'ClassSessions'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :class_session, in: :body, required: true, schema: {
        type: :object,
        properties: {
          class_session: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              start_time: { type: :string, description: 'ISO8601 datetime' },
              end_time: { type: :string, description: 'ISO8601 datetime' },
              instructor_id: { type: :integer },
              lounge_id: { type: :integer }
            },
            required: %i[name start_time end_time instructor_id lounge_id]
          }
        }
      }

      response(201, 'created') do
        let!(:lounge_design) { LoungeDesign.create!(name: 'Layout B', layout_json: { 'spaces' => [ { 'label' => 'B1', 'x' => 1, 'y' => 1 } ] }) }
        let!(:lounge) { Lounge.create!(name: 'Sala 2', description: 'Sala secundaria', lounge_design: lounge_design) }
        let!(:instructor) do
          User.create!(
            email: 'instructor2@classsessions.example.com',
            password: 'secret12',
            name: 'Inst2',
            last_name: 'Ructor2',
            phone: '5554445555',
            role: 'instructor',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end

        let(:class_session) do
          {
            class_session: {
              name: 'Nueva clase',
              description: 'Descripción',
              start_time: (Time.current + 3.days).iso8601,
              end_time: (Time.current + 3.days + 1.hour).iso8601,
              instructor_id: instructor.id,
              lounge_id: lounge.id
            }
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

  path '/api/v1/class_sessions/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'class session id'

    get('show class_session') do
      tags 'ClassSessions'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response(200, 'successful') do
        let!(:lounge_design) { LoungeDesign.create!(name: 'Layout C', layout_json: { 'spaces' => [ { 'label' => 'C1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:lounge) { Lounge.create!(name: 'Sala 3', description: 'Sala C', lounge_design: lounge_design) }
        let!(:instructor) do
          User.create!(
            email: 'instructor3@classsessions.example.com',
            password: 'secret12',
            name: 'Inst3',
            last_name: 'Ructor3',
            phone: '5556667777',
            role: 'instructor',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end
        let!(:record) { ClassSession.create!(name: 'Clase X', description: 'Detalle', start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour, instructor: instructor, lounge: lounge) }
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

    patch('update class_session') do
      tags 'ClassSessions'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :class_session, in: :body, schema: {
        type: :object,
        properties: {
          class_session: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let!(:lounge_design) { LoungeDesign.create!(name: 'Layout D', layout_json: { 'spaces' => [ { 'label' => 'D1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:lounge) { Lounge.create!(name: 'Sala 4', description: 'Sala D', lounge_design: lounge_design) }
        let!(:instructor) do
          User.create!(
            email: 'instructor4@classsessions.example.com',
            password: 'secret12',
            name: 'Inst4',
            last_name: 'Ructor4',
            phone: '5558889999',
            role: 'instructor',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end
        let!(:record) { ClassSession.create!(name: 'Clase Y', description: 'Detalle', start_time: 2.days.from_now, end_time: 2.days.from_now + 1.hour, instructor: instructor, lounge: lounge) }
        let(:id) { record.id }
        let(:class_session) { { description: 'Actualizada' } }

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

    delete('delete class_session (Soft Delete)') do
      tags 'ClassSessions'
      security [ bearerAuth: [] ]
      description "Soft deletes the class session. It will be retained for 8 days before permanent deletion. Customers cannot see it immediately. Admins can still access it during retention."

      response(204, 'no content') do
        let!(:lounge_design) { LoungeDesign.create!(name: 'Layout E', layout_json: { 'spaces' => [ { 'label' => 'E1', 'x' => 0, 'y' => 0 } ] }) }
        let!(:lounge) { Lounge.create!(name: 'Sala 5', description: 'Sala E', lounge_design: lounge_design) }
        let!(:instructor) do
          User.create!(
            email: 'instructor5@classsessions.example.com',
            password: 'secret12',
            name: 'Inst5',
            last_name: 'Ructor5',
            phone: '5551212121',
            role: 'instructor',
            gender: 'hombre',
            birthdate: '1990-01-01'
          )
        end
        let!(:record) { ClassSession.create!(name: 'Clase Z', description: 'Detalle', start_time: 3.days.from_now, end_time: 3.days.from_now + 1.hour, instructor: instructor, lounge: lounge) }
        let(:id) { record.id }

        run_test!
      end
    end
  end

  path '/api/v1/class_sessions/create_recurring' do
    post("create recurring class sessions") do
      tags 'ClassSessions'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :params, in: :body, required: true, schema: {
        type: :object,
        properties: {
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date },
          days_of_week: {
            type: :array,
            items: {
              type: :integer,
              description: 'Días de la semana (0 = domingo, 1 = lunes, 2 = martes, 3 = miércoles, 4 = jueves, 5 = viernes, 6 = sábado)'
            },
            example: [ 1, 3, 5 ]
          },
          class_session: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Yoga Matutino' },
              description: { type: :string, example: 'Clase recurrente de yoga' },
              start_time: { type: :string, example: '08:00' },
              end_time: { type: :string, example: '09:00' },
              instructor_id: { type: :integer },
              lounge_id: { type: :integer },
              price: { type: :integer, example: 100 }
            },
            required: %i[name start_time end_time instructor_id lounge_id price]
          }
        },
        required: %i[start_date end_date days_of_week class_session]
      }

      response(201, 'created') do
        let!(:lounge_design) { create(:lounge_design) }
        let!(:lounge) { create(:lounge, lounge_design: lounge_design) }
        let!(:instructor) { create(:user, role: 'instructor') }
        let(:start_date) { (Date.today + 1.week).iso8601 }
        let(:end_date) { (Date.today + 1.month).iso8601 }
        let(:days_of_week) { [ 1, 3, 5 ] }
        let(:class_session) { create(:class_session, instructor: instructor, lounge: lounge) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:params) do
          {
            start_date: nil,
            end_date: nil,
            days_of_week: [],
            class_session: {}
          }
        end

        run_test!
      end
    end
  end
end
