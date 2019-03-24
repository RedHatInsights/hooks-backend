# frozen_string_literal: true

app_count = ENV['APP_COUNT'] || 10
type_count = ENV['TYPE_COUNT'] || 5
level_count = ENV['LEVEL_COUNT'] || 5

ActiveRecord::Base.transaction do
  app_count.times do |app_id|
    Builder::App.build! do |app|
      app.name "seed-app-#{app_id}"
      random_event_type_count = Random.rand(type_count)
      random_level_count = Random.rand(level_count)
      random_event_type_count.times do |type_id|
        event_type = app.event_type "seed-type-#{type_id}"
        event_type.levels((0...random_level_count).map { |level_id| "level-#{level_id}" })
      end
    end
  end

  test_acc = Account.find_or_create_by(id: '00000000-0000-0000-0000-000000000000', account_number: '0000')
  test_acc.save!
  test_endpoint = Endpoints::HttpEndpoint.new(
    name: 'test_endpoint',
    url: 'http://endpoint:4567/logger',
    account: test_acc
  )
  test_filter = Filter.new(account_id: test_acc.id, endpoints: [test_endpoint]) # filter all
  test_filter.save!
end
