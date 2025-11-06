require 'swagger_helper'

RSpec.describe 'api/v1/reservations', type: :request do
  let!(:admin) do
    User.create!(
      email: 'admin@reservations.example.com',
      password: 'secret12',
      name: 'Admin',
      last_name: 'User',
      phone: '5550001111',
      role: 'admin',
      gender: 'hombre',
      birthdate: '1990-01-01'
    )
  end

  def setup_class_session_with_spaces
    design = LoungeDesign.create!(name: 'Layout R', layout_json: { 'spaces' => [
      { 'label' => 'R1', 'x' => 0, 'y' => 0 },
      { 'label' => 'R2', 'x' => 1, 'y' => 0 }
    ] })
    lounge = Lounge.create!(name: 'Sala R', description: 'Desc R', lounge_design: design)
    instructor = User.create!(
      email: 'instructor@reservations.example.com',
      password: 'secret12',
      name: 'Inst', last_name: 'Ructor', phone: '5552223333',
      role: 'instructor', gender: 'hombre', birthdate: '1990-01-01'
    )
    cs = ClassSession.create!(
      name: 'Clase Reserva', description: 'Para reservar',
      start_time: 1.day.from_now, end_time: 1.day.from_now + 1.hour,
      instructor: instructor, lounge: lounge
    )
    [ cs, cs.class_spaces ]
  end

  path '/api/v1/reservations' do
    get('list reservations') do
      tags 'Reservations'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :per_page, in: :query, schema: { type: :integer }
      parameter name: :user_id, in: :query, schema: { type: :integer }
      parameter name: :class_session_id, in: :query, schema: { type: :integer }
      parameter name: :class_space_id, in: :query, schema: { type: :integer }
      parameter name: :date_from, in: :query, schema: { type: :string, format: :date }
      parameter name: :date_to, in: :query, schema: { type: :string, format: :date }

      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'user@reservations.example.com', password: 'secret12', name: 'U', last_name: 'Ser',
            phone: '5553334444', role: 'user', gender: 'hombre', birthdate: '1990-01-01'
          )
        end
        before do
          @class_session, @spaces = setup_class_session_with_spaces
        end
        let!(:reservation) { Reservation.create!(user: user, class_session: @class_session, class_space: @spaces.first) }

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

    post('create reservation') do
      tags 'Reservations'
      consumes 'application/json'
      produces 'application/json'

      security [ bearerAuth: [] ]
      parameter name: :reservation, in: :body, required: true, schema: {
        type: :object,
        properties: {
          reservation: {
            type: :object,
            properties: {
              user_id: { type: :integer },
              class_session_id: { type: :integer },
              class_space_id: { type: :integer }
            },
            required: %i[user_id class_session_id class_space_id]
          }
        }
      }

      response(201, 'created') do
        let!(:user) do
          User.create!(
            email: 'user2@reservations.example.com', password: 'secret12', name: 'U2', last_name: 'Ser2',
            phone: '5555556666', role: 'user', gender: 'hombre', birthdate: '1990-01-01'
          )
        end
        before do
          @class_session, @spaces = setup_class_session_with_spaces
        end

        let(:reservation) do
          {
            user_id: user.id,
            class_session_id: @class_session.id,
            class_space_id: @spaces.first.id
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

  path '/api/v1/reservations/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'reservation id'

    get('show reservation') do
      tags 'Reservations'
      produces 'application/json'

      security [ bearerAuth: [] ]
      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'user3@reservations.example.com', password: 'secret12', name: 'U3', last_name: 'Ser3',
            phone: '5550002222', role: 'user', gender: 'hombre', birthdate: '1990-01-01'
          )
        end
        before do
          @class_session, @spaces = setup_class_session_with_spaces
        end
        let!(:record) { Reservation.create!(user: user, class_session: @class_session, class_space: @spaces.first) }
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

    patch('update reservation') do
      tags 'Reservations'
      consumes 'application/json'
      produces 'application/json'

      security [ bearerAuth: [] ]
      parameter name: :reservation, in: :body, schema: {
        type: :object,
        properties: {
          reservation: {
            type: :object,
            properties: {
              class_space_id: { type: :integer }
            }
          }
        }
      }

      response(200, 'successful') do
        let!(:user) do
          User.create!(
            email: 'user4@reservations.example.com', password: 'secret12', name: 'U4', last_name: 'Ser4',
            phone: '5551113333', role: 'user', gender: 'hombre', birthdate: '1990-01-01'
          )
        end
        before do
          @class_session, @spaces = setup_class_session_with_spaces
        end
        let!(:record) { Reservation.create!(user: user, class_session: @class_session, class_space: @spaces.first) }
        let(:id) { record.id }
        let(:reservation) { { class_space_id: @spaces.last.id } }

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

    delete('delete reservation') do
      tags 'Reservations'

      security [ bearerAuth: [] ]
      response(204, 'no content') do
        let!(:user) do
          User.create!(
            email: 'user5@reservations.example.com', password: 'secret12', name: 'U5', last_name: 'Ser5',
            phone: '5554447777', role: 'user', gender: 'hombre', birthdate: '1990-01-01'
          )
        end
        before do
          @class_session, @spaces = setup_class_session_with_spaces
        end
        let!(:record) { Reservation.create!(user: user, class_session: @class_session, class_space: @spaces.first) }
        let(:id) { record.id }

        run_test!
      end
    end
  end

  path '/api/v1/reservations/create_with_payment' do
    post('create reservation with payment') do
      tags 'Reservations'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          class_session_id: { type: :integer, example: 2 },
          class_space_id: { type: :integer, example: 1 }
        },
        required: %w[class_session_id class_space_id]
      }

      response(200, 'payment intent created successfully') do
        let(:Authorization) { "Bearer #{JwtService.encode({ sub: admin.id, role: admin.role }, exp: JwtService.access_exp.from_now)}" }
        let(:admin) { create(:user, role: :admin) }
        let(:class_session) { create(:class_session, price: 200) }
        let(:class_space) { create(:class_space) }

        let(:body) do
          {
            class_session_id: class_session.id,
            class_space_id: class_space.id
          }
        end

        # Stub para evitar llamada real a Stripe
        before do
          allow(Stripe::PaymentIntent).to receive(:create).and_return(
            OpenStruct.new(
              id: "pi_123",
              client_secret: "pi_123_secret_456"
            )
          )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['client_secret']).to eq('pi_123_secret_456')
        end
      end

      response(422, 'invalid parameters or internal error') do
        let(:Authorization) { "Bearer #{JwtService.encode({ sub: admin.id, role: admin.role }, exp: JwtService.access_exp.from_now)}" }
        let(:body) { { class_session_id: nil, class_space_id: nil } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to be_present
        end
      end
    end
  end
end
