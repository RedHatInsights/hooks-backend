class FilterTest < ActiveSupport::TestCase
  should have_many :endpoint_filters
  should have_many(:endpoints).through(:endpoint_filters)
  should have_many(:accounts).through(:endpoints)

  should have_many :severity_filters

  should have_many :app_filters
  should have_many(:apps).through(:app_filters)

  should have_many(:event_type_filters)
  should have_many(:event_types).through(:event_type_filters)
end

class SeverityFilterTest < ActiveSupport::TestCase
  should validate_presence_of(:severity)
  should belong_to(:filter)
end
