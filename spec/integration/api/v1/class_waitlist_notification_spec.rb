require 'swagger_helper'

RSpec.describe 'Api::V1::ClassWaitlistNotifications', type: :request do
  path '/api/v1/class_waitlist_notifications' do
    post('create class_waitlist_notification') do
      tags 'ClassWaitlistNotifications'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :class_waitlist_notification, in: :body, required: true, schema: {
        type: :object,
        properties: {
          class_session_id: { type: :integer }
        },
        required: %i[class_session_id]
      }
      response(201, 'created') do
        let!(:class_waitlist_notification) { build(:class_waitlist_notification) }
        after do |example|
          example.metadata[:response][:content] = { 'application/json' => { example: JSON.parse(response.body, symbolize_names: true) } }
        end
        run_test!
      end
    end
  end

  path '/api/v1/class_waitlist_notifications/{id}' do
    delete('destroy class_waitlist_notification') do
      tags 'ClassWaitlistNotifications'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :integer, description: 'class_waitlist_notification id'
      response(204, 'no content') do
        let!(:class_waitlist_notification) { create(:class_waitlist_notification) }
        let(:id) { class_waitlist_notification.id }
        after do |example|
          example.metadata[:response][:content] = { 'application/json' => { example: JSON.parse(response.body, symbolize_names: true) } }
        end
        run_test!
      end
    end
  end
end
