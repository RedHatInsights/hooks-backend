# frozen_string_literal: true

module Builder
  class Filter
    def initialize
      @apps = []
      @levels = []
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

    def build!(account)
      filter = ::Filter.new(:enabled => @enabled)
      filter.account = account
      filter.save!

      @apps.each { |builder| builder.build!(filter) }
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

        event_type = app.event_types.where(:external_id => @name).first
        filter.event_types << event_type
        @children.each { |builder| builder.build!(filter, event_type) }
      end

      def level(name = nil)
        builder = Level.new(name)
        @children << builder
        yield builder if block_given?
        builder
      end

      def levels(names)
        names.each { |name| level name }
      end
    end

    class Level < Common
      alias level name

      def build!(filter, event_type)
        filter.levels << event_type.levels.where(:external_id => @name).first if @name != ANY
      end
    end
  end
end
