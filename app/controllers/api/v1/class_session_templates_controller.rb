class Api::V1::ClassSessionTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: %i[ show update duplicate archive preview publish ]

  def index
    authorize ClassSessionTemplate
    templates = ClassSessionTemplate.includes(:items).order(created_at: :desc)
    render json: templates,
           each_serializer: Api::V1::ClassSessionTemplateSerializer
  end

  def show
    authorize @template
    render json: @template, serializer: Api::V1::ClassSessionTemplateSerializer
  end

  def create
    @template = ClassSessionTemplate.new(template_attributes)
    authorize @template
    if @template.save
      render json: @template, serializer: Api::V1::ClassSessionTemplateSerializer, status: :created
    else
      template_invalid(@template)
    end
  end

  def update
    authorize @template
    if update_template
      render json: @template, serializer: Api::V1::ClassSessionTemplateSerializer
    else
      template_invalid(@template)
    end
  end

  def duplicate
    authorize @template
    copy = @template.dup
    copy.name = "#{@template.name} (copia)"
    copy.items = @template.items.map(&:dup)
    if copy.save
      render json: copy, serializer: Api::V1::ClassSessionTemplateSerializer, status: :created
    else
      template_invalid(copy)
    end
  end

  def archive
    authorize @template
    @template.update!(status: "archived")
    render json: @template, serializer: Api::V1::ClassSessionTemplateSerializer
  end

  def preview
    authorize @template
    result = ClassSessionTemplates::WeeklyPublisher.preview(template: @template, week_start: publication_params[:week_start])
    render json: preview_json(result)
  rescue ClassSessionTemplates::WeeklyPublisher::ValidationError => e
    render_api_error(code: "CLASS_SESSION_TEMPLATE_INVALID", message: e.message, field_errors: e.field_errors, status: :unprocessable_entity)
  end

  def publish
    authorize @template
    payload = { template_id: @template.id, week_start: publication_params[:week_start] }

    execute_idempotent(endpoint: request.path, payload: payload) do
      result = ClassSessionTemplates::WeeklyPublisher.publish(
        template: @template,
        week_start: publication_params[:week_start]
      )
      {
        body: publication_json(result),
        status: :created
      }
    end
  rescue ClassSessionTemplates::WeeklyPublisher::ValidationError => e
    render_api_error(code: "CLASS_SESSION_TEMPLATE_INVALID", message: e.message, field_errors: e.field_errors, status: :unprocessable_entity)
  end

  private

  def set_template
    @template = ClassSessionTemplate.includes(:items).find(params[:id])
  end

  def template_attributes
    permitted = params.require(:class_session_template).permit(:name, :description, items: %i[
      id day_of_week start_time end_time name description instructor_id lounge_id price _destroy
    ])
    permitted[:items_attributes] = permitted.delete(:items) if permitted.key?(:items)
    permitted
  end

  def update_template
    attributes = template_attributes
    return @template.update(attributes) unless attributes.key?(:items_attributes)

    item_attributes = attributes.delete(:items_attributes)
    ClassSessionTemplate.transaction do
      retained_ids = item_attributes.each_with_object([]) do |item, ids|
        ids << item[:id].to_i if item[:id].present? && !ActiveModel::Type::Boolean.new.cast(item[:_destroy])
      end

      @template.items.where.not(id: retained_ids).destroy_all
      @template.update!(attributes.merge(items_attributes: item_attributes))
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def publication_params
    params.require(:publication).permit(:week_start)
  end

  def preview_json(result)
    {
      week_start: result[:week_start].iso8601,
      sessions: result[:candidates].map { |candidate| candidate_json(candidate) },
      conflicts: result[:conflicts]
    }
  end

  def publication_json(result)
    {
      template_id: @template.id,
      publication_id: result[:publication].id,
      week_start: result[:week_start].iso8601,
      created: result[:sessions].length,
      sessions: ActiveModelSerializers::SerializableResource.new(
        result[:sessions], each_serializer: Api::V1::ClassSessionSerializer
      ).as_json
    }
  end

  def candidate_json(candidate)
    {
      item_index: candidate[:item_index],
      name: candidate[:name],
      description: candidate[:description],
      start_time: candidate[:start_time].in_time_zone("America/Mexico_City").iso8601,
      end_time: candidate[:end_time].in_time_zone("America/Mexico_City").iso8601,
      instructor_id: candidate[:instructor_id],
      lounge_id: candidate[:lounge_id],
      price: candidate[:price]
    }
  end

  def template_invalid(template)
    render_api_error(
      code: "CLASS_SESSION_TEMPLATE_INVALID",
      message: "No fue posible guardar la plantilla",
      field_errors: template.errors.to_hash,
      status: :unprocessable_entity
    )
  end
end
