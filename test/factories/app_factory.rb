# frozen_string_literal: true

FactoryBot.define do
  factory :app, :class => ::App do
    sequence(:name) { |i| "app#{i}" }
    sequence(:title) { |i| "App #{i}" }

    trait :with_event_type do
      after(:create) do |instance|
        create :event_type, :with_levels, :app => instance
      end
    end
  end
end
