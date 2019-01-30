# frozen_string_literal: true

# Represents a Insights account. An account can be composed of many users
class Account < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :endpoints, :dependent => :destroy
  has_many :filters, :dependent => :destroy
end
