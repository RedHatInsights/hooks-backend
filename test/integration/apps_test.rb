# frozen_string_literal: true

require 'integration_test_helper'

class AppsTest < CommitteeTest
  test 'Lists applications according to schema' do
    FactoryBot.create(:app, :with_event_type)

    get apps_path, headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_schema_conform
  end

  test 'Shows a single app' do
    id = FactoryBot.create(:app, :with_event_type).id

    get app_path(id: id), headers: { 'X-RH-IDENTITY' => encoded_header }

    assert_schema_conform
  end
end
