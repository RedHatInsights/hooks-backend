# frozen_string_literal: true

FactoryBot.define do
  factory :account, :class => ::Account do
    sequence(:account_number) { |i| format '%<account_number>05d', account_number: i }

    trait :with_user do
      after(:create) do |instance|
        instance.users << FactoryBot.build(:user)
      end
    end
  end
end
