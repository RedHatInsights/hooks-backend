# frozen_string_literal: true

class Filter < ApplicationRecord
  has_many :accounts, :through => :endpoints

  has_many :endpoint_filters
  has_many :endpoints, :through => :endpoint_filters

  has_many :severity_filters, :dependent => :destroy

  has_many :app_filters
  has_many :apps, :through => :app_filters, :dependent => :destroy

  has_many :event_type_filters
  has_many :event_types, :through => :event_type_filters, :dependent => :destroy

  class << self
    def matching_message(message)
      sql = <<~SQL
        SELECT filters.* FROM filters
          LEFT OUTER JOIN app_filters
            ON app_filters.filter_id = filters.id
          LEFT OUTER JOIN event_type_filters
            ON event_type_filters.filter_id = filters.id
          LEFT OUTER JOIN severity_filters
            ON severity_filters.filter_id = filters.id
          LEFT OUTER JOIN apps
            ON apps.id = app_filters.app_id
          LEFT OUTER JOIN event_types
            ON event_types.id = event_type_filters.event_type_id AND event_types.app_id = apps.id
          WHERE
            (app_filters.app_id IS NULL
              OR
              (apps.name = ?
                AND
                (event_type_filters.event_type_id IS NULL
                  OR event_types.name = ?)))
             AND (severity_filters.filter_id IS NOT NULL
                   AND (severity_filters.severity IN (?)
                         OR severity_filters.severity IS NULL))
      SQL
      Filter.find_by_sql sanitize_sql_array([sql, message[:application], message[:type], message[:severity]])
    end
  end
end
