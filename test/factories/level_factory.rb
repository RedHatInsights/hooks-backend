# frozen_string_literal: true

FactoryBot.define do
  factory :level, :class => ::Level do
    sequence(:title) { |i| "Level #{i}" }
    sequence(:external_id) { |i| "my-custom-id:#{i}" }

    trait :with_event_type do
      association(:event_type, :factory => %i[event_type with_app])
    end
  end
end
