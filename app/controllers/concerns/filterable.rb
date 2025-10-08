module Filterable
  extend ActiveSupport::Concern

  private

  def apply_filters(collection, filter_params)
    return collection if filter_params.blank?

    filter_params.each do |key, value|
      next if value.blank?

      case key.to_s
      when "search"
        collection = apply_search_filter(collection, value)
      when "date_from", "date_to"
        collection = apply_date_filter(collection, key, value)
      when "role"
        collection = apply_role_filter(collection, value)
      when "gender"
        collection = apply_gender_filter(collection, value)
      when "severity"
        collection = apply_severity_filter(collection, value)
      when "recovered"
        collection = apply_recovered_filter(collection, value)
      when "instructor_id"
        collection = apply_instructor_filter(collection, value)
      when "user_id"
        collection = apply_user_filter(collection, value)
      when "class_session_id"
        collection = apply_class_session_filter(collection, value)
      when "injury_type"
        collection = apply_injury_type_filter(collection, value)
      when "capacity_min", "capacity_max"
        collection = apply_capacity_filter(collection, key, value)
      when "start_time_from", "start_time_to"
        collection = apply_time_filter(collection, key, value)
      end
    end

    collection
  end

  def apply_search_filter(collection, search_term)
    if collection.model == User
      collection.where(
        "name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
        "%#{search_term}%", "%#{search_term}%", "%#{search_term}%"
      )
    elsif collection.model == Injury
      collection.where(
        "injury_type ILIKE ? OR description ILIKE ?",
        "%#{search_term}%", "%#{search_term}%"
      )
    elsif collection.model == ClassSession
      collection.where(
        "name ILIKE ? OR description ILIKE ?",
        "%#{search_term}%", "%#{search_term}%"
      )
    else
      collection
    end
  end

  def apply_date_filter(collection, date_key, date_value)
    date = Date.parse(date_value) rescue nil
    return collection unless date

    if collection.model == User
      case date_key
      when "date_from"
        collection.where("created_at >= ?", date.beginning_of_day)
      when "date_to"
        collection.where("created_at <= ?", date.end_of_day)
      end
    elsif collection.model == Injury
      case date_key
      when "date_from"
        collection.where("date_ocurred >= ?", date.beginning_of_day)
      when "date_to"
        collection.where("date_ocurred <= ?", date.end_of_day)
      end
    elsif collection.model == ClassSession
      case date_key
      when "date_from"
        collection.where("start_time >= ?", date.beginning_of_day)
      when "date_to"
        collection.where("start_time <= ?", date.end_of_day)
      end
    elsif collection.model == Reservation
      case date_key
      when "date_from"
        collection.joins(:class_session).where("class_sessions.start_time >= ?", date.beginning_of_day)
      when "date_to"
        collection.joins(:class_session).where("class_sessions.start_time <= ?", date.end_of_day)
      end
    else
      collection
    end
  end

  def apply_role_filter(collection, role)
    return collection unless collection.model == User
    collection.where(role: role)
  end

  def apply_gender_filter(collection, gender)
    return collection unless collection.model == User
    collection.where(gender: gender)
  end

  def apply_severity_filter(collection, severity)
    return collection unless collection.model == Injury
    collection.where(severity: severity)
  end

  def apply_recovered_filter(collection, recovered)
    return collection unless collection.model == Injury
    collection.where(recovered: ActiveModel::Type::Boolean.new.cast(recovered))
  end

  def apply_instructor_filter(collection, instructor_id)
    return collection unless collection.model == ClassSession
    collection.where(instructor_id: instructor_id)
  end

  def apply_user_filter(collection, user_id)
    if collection.model == Reservation
      collection.where(user_id: user_id)
    elsif collection.model == Injury
      collection.where(user_id: user_id)
    else
      collection
    end
  end

  def apply_class_session_filter(collection, class_session_id)
    return collection unless collection.model == Reservation
    collection.where(class_session_id: class_session_id)
  end

  def apply_injury_type_filter(collection, injury_type)
    return collection unless collection.model == Injury
    collection.where(injury_type: injury_type)
  end

  def apply_capacity_filter(collection, capacity_key, capacity_value)
    return collection unless collection.model == ClassSession
    capacity = capacity_value.to_i rescue nil
    return collection unless capacity

    case capacity_key
    when "capacity_min"
      collection.where("capacity >= ?", capacity)
    when "capacity_max"
      collection.where("capacity <= ?", capacity)
    end
  end

  def apply_time_filter(collection, time_key, time_value)
    return collection unless collection.model == ClassSession
    time = Time.parse(time_value) rescue nil
    return collection unless time

    case time_key
    when "start_time_from"
      collection.where("start_time >= ?", time)
    when "start_time_to"
      collection.where("start_time <= ?", time)
    end
  end

  def paginate_collection(collection, page: 1, per_page: 10)
    page = [ page.to_i, 1 ].max
    per_page = [ [ per_page.to_i, 1 ].max, 100 ].min # Limit to max 100 items per page

    collection.page(page).per(per_page)
  end

  def pagination_metadata(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value,
      has_next_page: collection.next_page.present?,
      has_prev_page: collection.prev_page.present?
    }
  end
end
