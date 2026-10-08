require "rails_helper"

RSpec.describe "api/v1/class_session_templates", type: :request do
  def auth_headers(user, extra = {})
    token = JwtService.encode({ sub: user.id, role: user.role }, exp: JwtService.access_exp.from_now)
    { "Authorization" => "Bearer #{token}" }.merge(extra)
  end

  let!(:admin) { create(:user, role: :admin) }
  let!(:instructor) { create(:user, role: :instructor) }
  let!(:lounge) { create(:lounge) }
  let(:week_start) { Date.current.next_occurring(:monday) }

  let(:template_payload) do
    {
      class_session_template: {
        name: "Semana Pilates",
        description: "Programación estándar",
        items: [
          {
            day_of_week: 1,
            start_time: "08:00",
            end_time: "09:00",
            name: "Pilates matutino",
            description: "Nivel básico",
            instructor_id: instructor.id,
            lounge_id: lounge.id,
            price: 250
          },
          {
            day_of_week: 3,
            start_time: "10:00",
            end_time: "11:00",
            name: "Pilates intermedio",
            description: "Nivel intermedio",
            instructor_id: instructor.id,
            lounge_id: lounge.id,
            price: 275
          }
        ]
      }
    }
  end

  def create_template
    post "/api/v1/class_session_templates", params: template_payload, headers: auth_headers(admin), as: :json
    expect(response).to have_http_status(:created)
    ClassSessionTemplate.last
  end

  it "creates and lists a reusable weekly template" do
    create_template

    get "/api/v1/class_session_templates", headers: auth_headers(admin)

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body.first["name"]).to eq("Semana Pilates")
    expect(body.first["items"].size).to eq(2)
  end

  it "replaces omitted items when updating a template" do
    template = create_template
    kept_item = template.items.order(:id).first

    patch "/api/v1/class_session_templates/#{template.id}",
          params: {
            class_session_template: {
              name: "Semana actualizada",
              items: [
                {
                  id: kept_item.id,
                  day_of_week: kept_item.day_of_week,
                  start_time: "09:00",
                  end_time: "10:00",
                  name: "Bloque conservado",
                  instructor_id: instructor.id,
                  lounge_id: lounge.id,
                  price: 300
                }
              ]
            }
          },
          headers: auth_headers(admin),
          as: :json

    expect(response).to have_http_status(:ok)
    expect(template.reload.items.count).to eq(1)
    expect(template.items.first.id).to eq(kept_item.id)
    expect(template.items.first.start_time.strftime("%H:%M")).to eq("09:00")
  end

  it "previews a target week without creating sessions" do
    template = create_template
    sessions_before = ClassSession.count

    post "/api/v1/class_session_templates/#{template.id}/preview",
         params: { publication: { week_start: week_start.iso8601 } },
         headers: auth_headers(admin),
         as: :json

    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body["week_start"]).to eq(week_start.iso8601)
    expect(body["sessions"].size).to eq(2)
    expect(ClassSession.count).to eq(sessions_before)
  end

  it "publishes a template atomically and is idempotent" do
    template = create_template
    key = SecureRandom.uuid
    params = { publication: { week_start: week_start.iso8601 } }
    sessions_before = ClassSession.count

    post "/api/v1/class_session_templates/#{template.id}/publish",
         params: params,
         headers: auth_headers(admin, "Idempotency-Key" => key),
         as: :json

    expect(response).to have_http_status(:created)
    expect(ClassSession.count).to eq(sessions_before + 2)
    publication_id = JSON.parse(response.body)["publication_id"]

    post "/api/v1/class_session_templates/#{template.id}/publish",
         params: params,
         headers: auth_headers(admin, "Idempotency-Key" => key),
         as: :json

    expect(response).to have_http_status(:ok)
    expect(response.headers["Idempotency-Replayed"]).to eq("true")
    expect(JSON.parse(response.body)["publication_id"]).to eq(publication_id)
    expect(ClassSession.count).to eq(sessions_before + 2)
  end

  it "rejects a conflicting publication without creating anything" do
    template = create_template
    start_time = Time.zone.parse("#{week_start} 08:30")
    create(:class_session,
           start_time: start_time,
           end_time: start_time + 1.hour,
           instructor: instructor,
           lounge: lounge)
    sessions_before = ClassSession.count

    post "/api/v1/class_session_templates/#{template.id}/publish",
         params: { publication: { week_start: week_start.iso8601 } },
         headers: auth_headers(admin, "Idempotency-Key" => SecureRandom.uuid),
         as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)["code"]).to eq("CLASS_SESSION_TEMPLATE_INVALID")
    expect(ClassSessionTemplatePublication.count).to eq(0)
    expect(ClassSession.count).to eq(sessions_before)
  end

  it "allows only admins to publish templates" do
    template = create_template

    post "/api/v1/class_session_templates/#{template.id}/publish",
         params: { publication: { week_start: "2026-10-05" } },
         headers: auth_headers(instructor, "Idempotency-Key" => SecureRandom.uuid),
         as: :json

    expect(response).to have_http_status(:forbidden)
  end
end
