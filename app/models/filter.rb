# frozen_string_literal: true

class Filter < ApplicationRecord
  belongs_to :account
  validates_associated :account

  has_many :endpoint_filters, :dependent => :destroy
  has_many :endpoints, :through => :endpoint_filters, :inverse_of => :filters

  has_many :severity_filters, :dependent => :destroy

  has_many :app_filters, :dependent => :destroy
  has_many :apps, :through => :app_filters, :dependent => :destroy, :inverse_of => :filters

  has_many :event_type_filters, :dependent => :destroy
  has_many :event_types, :through => :event_type_filters, :dependent => :destroy, :inverse_of => :filters

  scope(:matching_message, lambda do |message|
    left_outer_joins(:apps, :event_types, :severity_filters)
      .where(:enabled => true, :account_id => message[:account_id])
      .merge(App.where(:name => [message[:application], nil]))
      .merge(EventType.where(:name => [message[:type], nil]))
      .merge(SeverityFilter.where(:severity => [message[:severity], nil]))
      .distinct
  end)
end
