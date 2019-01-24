FactoryBot.define do
  factory :event_type, :class => ::EventType do
    sequence(:name) { |i| "event_type-#{i}" }

    trait :with_app do
      after(:build) do |instance|
        instance.app = FactoryBot.create(:app)
      end
    end
  end
end
