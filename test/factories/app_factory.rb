# frozen_string_literal: true
FactoryBot.define do
  factory :app, :class => ::App do
    sequence(:name) { |i| "app#{i}" }

    trait :with_event_type do
      after(:create) do |instance|
        instance.event_types << FactoryBot.build(:event_type)
      end
    end
  end
end
