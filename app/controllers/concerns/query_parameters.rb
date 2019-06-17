# frozen_string_literal: true

class UnknownSearch < RuntimeError; end

module QueryParameters
  extend ActiveSupport::Concern

  include ActiveRecord::Sanitization

  ESCAPE_CHAR = '\\'

  def query_fields
    search_query_parameter.split(',').map { |condition| parse_search_condition(condition) }
  end

  def search_query_parameter
    (params[:q] || '')
  end

  def parse_search_condition(condition)
    field, value = condition.split('~')

    unless field && value
      raise UnknownSearch, "#{condition} is not valid search codition, should be field~value"
    end

    unless self.class.allowed_search_fields.include?(field)
      raise UnknownSearch, "#{field} is not marked searchable"
    end

    value = self.class.sanitize_sql_like(value, ESCAPE_CHAR)

    [field, to_like_term(value)]
  end

  def generate_query_arel(model)
    return nil if search_query_parameter.empty?

    if search_query_parameter.include?(',') || search_query_parameter.include?('~')
      generate_per_field_query(model)
    else
      generate_multi_field_query(model)
    end
  end

  def generate_per_field_query(model)
    arel = model.arel_table
    likes = query_fields.map do |field, value|
      arel[field.to_sym].matches(value, ESCAPE_CHAR)
    end

    likes.reduce(:and)
  end

  def generate_multi_field_query(model)
    arel = model.arel_table
    term = to_like_term(params[:q])
    likes = self.class.allowed_search_fields.map do |field|
      arel[field.to_sym].matches(term, ESCAPE_CHAR)
    end

    likes.reduce(:or)
  end

  def to_like_term(query)
    "%#{query}%"
  end

  module ClassMethods
    def allowed_search_fields
      @allowed_search_fields ||= []
    end

    def allow_search_on(*fields)
      allowed_search_fields.concat(fields.map(&:to_s))
    end
  end
end
