# frozen_string_literal: true

app_count = ENV['APP_COUNT'] || 10
type_count = ENV['TYPE_COUNT'] || 5

ActiveRecord::Base.transaction do
  app_count.times do |app_id|
    Builder::App.build! do |app|
      app.name "seed-app-#{app_id}"
      event_type_count = Random.rand(type_count)
      event_type_count.times do |type_id|
        app.event_type "seed-type-#{type_id}"
      end
    end
  end
end
