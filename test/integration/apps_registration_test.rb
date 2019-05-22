# frozen_string_literal: true

require 'integration_test_helper'

class AppsRegistrationTest < CommitteeTest
  test 'Registers an application' do
    app = { :name => 'app-1', :title => 'Application 1' }
    levels = [
      { :id => 'level-1', :title => 'Low' },
      { :id => 'level-2', :title => 'High' }
    ]
    event_types = [
      { :id => 'something', :title => 'Something', :levels => [] },
      { :id => 'something-else', :title => 'Something else', :levels => levels }
    ]
    application = { :application => app, :event_types => event_types }

    post register_apps_path, params: application, as: :json

    assert_schema_conform
  end
end
