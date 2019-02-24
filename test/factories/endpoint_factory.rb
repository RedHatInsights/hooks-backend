# frozen_string_literal: true

FactoryBot.define do
  factory :endpoint, :class => ::Endpoint do
    sequence(:name) { |i| "endpoint#{i}" }
    sequence(:url) { |i| "https://something.somewhere.com?foo=#{i}" }
    type { ::Endpoint.name }

    trait :with_account do
      association :account, :factory => :account
    end

    factory :http_endpoint, class: Endpoints::HttpEndpoint do
      type { Endpoints::HttpEndpoint.name }
    end
  end
end
