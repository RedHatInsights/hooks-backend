# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :account, :inverse_of => :endpoints

  has_one :filter, :dependent => :destroy

  accepts_nested_attributes_for :filter, allow_destroy: true

  validates :name, :presence => true,
                   :uniqueness => { :scope => :account_id }
  validates :url, :presence => true

  def send_message(*)
    raise 'Inherited class must be used to send mesages'
  end

  def self.policy_class
    ::EndpointPolicy
  end
end
