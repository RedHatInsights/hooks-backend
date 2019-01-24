FactoryBot.define do
  factory :user, :class => ::User do
    sequence(:username) { |i| "testuser#{i}@redhat.com" }
    sequence(:account_id) { |i| sprintf('%07d', i) }
    sequence(:redhat_id) { |i| "rh#{i}" }
  end
end
