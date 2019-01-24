FactoryBot.define do
  factory :endpoint, :class => ::Endpoint do
    sequence(:name) { |i| "endpoint#{i}" }
    sequence(:url) { |i| "https://something.somewhere.com?foo=#{i}" }

    trait :with_account do
      after(:build) do |instance|
        instance.account = FactoryBot.create(:account)
      end
    end
  end
end
