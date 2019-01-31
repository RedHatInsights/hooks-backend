# frozen_string_literal: true

FactoryBot.define do
  factory :user, :class => ::User do
    sequence(:username) { |i| "testuser#{i}@redhat.com" }
    sequence(:redhat_id) { |i| "rh#{i}" }
    association :account, :factory => :account
  end
end
