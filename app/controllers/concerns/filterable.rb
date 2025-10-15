module Filterable
  extend ActiveSupport::Concern

  private

  # Keep only pagination helpers here; move filtering per resource to services
  def paginate_collection(collection, page: 1, per_page: 10)
    page = [ page.to_i, 1 ].max
    per_page = [ [ per_page.to_i, 1 ].max, 100 ].min
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
