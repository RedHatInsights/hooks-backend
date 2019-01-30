# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

app_count = ENV['APP_COUNT'] || 100
type_count = ENV['TYPE_COUNT'] || 10

ActiveRecord::Base.transaction do
  app_count.times do |app_id|
    app = Builder::App.build! do |app|
      app.name "seed-app-#{app_id}"

      Random.rand(type_count).times do |type_id|
        app.event_type "seed-type-#{type_id}"
      end
    end

    Builder::Filter.build! do |filter|
      filter.application(app.name)
            .event_types(app.event_types.pluck(:name))
    end
  end
end