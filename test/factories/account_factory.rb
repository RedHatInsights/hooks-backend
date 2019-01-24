FactoryBot.define do
  factory :account, :class => ::Account do
    sequence(:account_number) { |i| format '%05d', i }

    trait :with_user do
      after(:create) do |instance|
        instance.users << FactoryBot.build(:user)
      end
    end
  end
end
