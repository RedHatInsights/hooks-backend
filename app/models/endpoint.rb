# frozen_string_literal: true

class Endpoint < ApplicationRecord
  belongs_to :account, :inverse_of => :endpoints

  has_many :endpoint_filters, :dependent => :destroy
  has_many :filters, :through => :endpoint_filters, :dependent => :destroy, :inverse_of => :endpoints

  validates :name, :presence => true
  validates :url, :presence => true

  def send_message(_timestamp:, _level:, _message:)
    raise 'Inherited class must be used to send mesages'
  end
end
