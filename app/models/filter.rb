class Filter < ApplicationRecord
  has_many :accounts, :through => :endpoints

  has_many :endpoint_filters
  has_many :endpoints, :through => :endpoint_filters

  has_many :severity_filters, :dependent => :destroy

  has_many :app_filters
  has_many :apps, :through => :app_filters, :dependent => :destroy

  has_many :event_type_filters
  has_many :event_types, :through => :event_type_filters, :dependent => :destroy
end
