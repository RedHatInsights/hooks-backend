# frozen_string_literal: true

class Filter < ApplicationRecord
  belongs_to :account
  validates_associated :account

  belongs_to :endpoint
  validates_presence_of :endpoint

  has_many :level_filters, :dependent => :destroy
  has_many :levels, :through => :level_filters, :inverse_of => :filters

  has_many :app_filters, :dependent => :destroy
  has_many :apps, :through => :app_filters, :dependent => :destroy, :inverse_of => :filters

  has_many :event_type_filters, :dependent => :destroy
  has_many :event_types, :through => :event_type_filters, :dependent => :destroy, :inverse_of => :filters

  scope(:matching_message, lambda do |message|
    left_outer_joins(:apps, :event_types, :levels, :account)
      .where(:enabled => true)
      .merge(Account.where(:account_number => message.account_id))
      .merge(App.where(:name => [message.application, nil]))
      .merge(EventType.where(:external_id => [message.event_type, nil]))
      .merge(Level.where(:external_id => [message.level, nil]))
      .distinct
  end)
end
