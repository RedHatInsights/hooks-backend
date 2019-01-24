# frozen_string_literal: true
FactoryBot.define do
  factory :app, :class => ::App do
    sequence(:name) { |i| "app#{i}" }
  end
end
