# frozen_string_literal: true

module Builder
  class Filter
    def initialize
      @apps = []
      @severities = []
      @enabled = true
    end

    def application(name = nil, *event_types)
      builder = Application.new(name, *event_types)
      @apps << builder
      yield builder if block_given?
      builder
    end

    def disabled!
      @enabled = false
    end

    def severity(name = nil)
      builder = Severity.new(name)
      @severities << builder
      yield builder if block_given?
      builder
    end

    def severities(*args)
      args.each { |arg| severity(arg) }
    end

    def build!(account)
      filter = ::Filter.new(:enabled => @enabled)
      filter.account = account
      filter.save!

      [@apps, @severities].each do |group|
        group.each { |builder| builder.build!(filter) }
      end
      filter
    end

    def self.build!(account)
      builder = new
      yield builder
      builder.build!(account)
    end

    class Common
      ANY = 0

      def initialize(name = nil)
        name(name)
        @children = []
      end

      # rubocop:disable Style/TrivialAccessors
      def name(name)
        @name = name
      end
      # rubocop:enable Style/TrivialAccessors

      def any!
        @name = ANY
        self
      end

      def build!(_filter)
        raise NotImplementedError
      end
    end

    class Application < Common
      def initialize(name = nil, *event_types)
        super(name)
        event_types.each { |type| event_type type }
      end

      def event_type(name = nil)
        builder = EventType.new(name)
        @children << builder
        yield builder if block_given?
        builder
      end

      def event_types(types)
        types.each { |type| event_type(type) }
      end

      def build!(filter)
        return if @name == ANY

        app = ::App.find_by(:name => @name)
        filter.apps << app
        @children.each { |builder| builder.build!(filter, app) }
      end
    end

    class EventType < Common
      def build!(filter, app)
        return if @name == ANY

        filter.event_types << app.event_types.where(:name => @name).first
        @children.each { |builder| builder.build!(filter) }
      end
    end

    class Severity < Common
      alias severity name

      def build!(filter)
        filter.severity_filters.create(:severity => @name) if @name != ANY
      end
    end
  end
end
