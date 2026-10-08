module ClassSessionTemplates
  class WeeklyPublisher
    class ValidationError < StandardError
      attr_reader :field_errors

      def initialize(message, field_errors = {})
        super(message)
        @field_errors = field_errors
      end
    end

    def self.preview(template:, week_start:)
      new(template: template, week_start: week_start).preview
    end

    def self.publish(template:, week_start:)
      new(template: template, week_start: week_start).publish
    end

    def initialize(template:, week_start:)
      @template = template
      @week_start = parse_week_start(week_start)
    end

    def preview
      candidates = build_plan
      { week_start: @week_start, candidates: candidates, conflicts: [] }
    end

    def publish
      raise ValidationError, "La plantilla está archivada" unless @template.status == "active"

      ClassSessionTemplatePublication.transaction do
        lock_resources!
        ensure_not_published!
        candidates = build_plan
        publication = @template.publications.create!(week_start: @week_start)
        sessions = candidates.map do |attributes|
          session_attributes = attributes.except(:item_index, :item)
          ClassSession.create!(session_attributes.merge(class_session_template_publication: publication))
        end

        { week_start: @week_start, publication: publication, sessions: sessions }
      end
    rescue ActiveRecord::RecordNotUnique
      raise ValidationError.new("La plantilla ya fue publicada para esa semana", "week_start" => [ "ya fue publicada" ])
    end

    private

    def parse_week_start(value)
      date = Date.iso8601(value.to_s)
      raise ValidationError.new("week_start debe ser una fecha ISO válida", "week_start" => [ "formato inválido" ]) unless date.monday?

      date
    rescue ArgumentError
      raise ValidationError.new("week_start debe ser una fecha ISO válida", "week_start" => [ "formato inválido" ])
    end

    def build_plan
      errors = {}
      errors["template"] = @template.errors.full_messages unless @template.valid?
      errors["items"] = [ "La plantilla debe tener al menos un bloque" ] if @template.items.empty?
      raise ValidationError.new("La plantilla no es válida", errors) if errors.any?

      candidates = @template.items.order(:day_of_week, :start_time, :id).each_with_index.map do |item, index|
        # Keep the same convention as create_recurring: 0 = Sunday, 1 = Monday...
        day_offset = (item.day_of_week - 1) % 7
        start_time = combine_date_and_time(@week_start + day_offset.days, item.start_time)
        end_time = combine_date_and_time(@week_start + day_offset.days, item.end_time)
        {
          item_index: index,
          item: item,
          name: item.name,
          description: item.description,
          start_time: start_time,
          end_time: end_time,
          instructor_id: item.instructor_id,
          lounge_id: item.lounge_id,
          price: item.price
        }
      end

      conflicts = find_conflicts(candidates)
      return candidates if conflicts.empty?

      raise ValidationError.new("La semana tiene conflictos", { "sessions" => conflicts })
    end

    def combine_date_and_time(date, time)
      Time.zone.parse("#{date} #{time.strftime('%H:%M:%S')}")
    end

    def find_conflicts(candidates)
      conflicts = []

      candidates.combination(2) do |left, right|
        next unless overlapping?(left, right)
        next unless left[:lounge_id] == right[:lounge_id] || left[:instructor_id] == right[:instructor_id]

        conflicts << {
          "item_index" => left[:item_index],
          "conflicts_with_item_index" => right[:item_index],
          "reason" => "Los bloques se superponen en el mismo salón o con el mismo instructor"
        }
      end

      candidates.each do |candidate|
        existing_sessions(candidate).each do |session|
          conflicts << {
            "item_index" => candidate[:item_index],
            "class_session_id" => session.id,
            "reason" => "Ya existe una sesión superpuesta en el salón o con el instructor"
          }
        end
      end

      conflicts
    end

    def existing_sessions(candidate)
      ClassSession.active
                  .where.not(lifecycle_status: "canceled")
                  .where(
                    "lounge_id = :lounge_id OR instructor_id = :instructor_id",
                    lounge_id: candidate[:lounge_id], instructor_id: candidate[:instructor_id]
                  )
                  .where(
                    "start_time < :end_time AND end_time > :start_time",
                    start_time: candidate[:start_time], end_time: candidate[:end_time]
                  )
    end

    def overlapping?(left, right)
      left[:start_time] < right[:end_time] && right[:start_time] < left[:end_time]
    end

    def lock_resources!
      lounge_ids = @template.items.pluck(:lounge_id).compact.uniq
      Lounge.where(id: lounge_ids).lock.load
      ClassSessionTemplatePublication.where(class_session_template: @template, week_start: @week_start).lock.load
    end

    def ensure_not_published!
      return unless @template.publications.exists?(week_start: @week_start)

      raise ValidationError.new("La plantilla ya fue publicada para esa semana", "week_start" => [ "ya fue publicada" ])
    end
  end
end
