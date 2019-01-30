module Builder
  class Filter
    def initialize
      @apps = []
      @severities = []
    end

    def application(name = nil, *event_types)
      builder = Application.new(name, *event_types)
      @apps << builder
      yield builder if block_given?
      builder
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

    def build!(arg = nil)
      filter = ::Filter.new
      filter.save!

      [@apps, @severities].each do |group|
        group.each { |builder| builder.build!(filter) }
      end
      filter
    end

    def self.build!
      builder = self.new
      yield builder
      builder.build!
    end

    class Common
      ANY = 0

      def initialize(name = nil)
        name(name)
        @children = []
      end

      def name(name)
        @name = name
      end

      def any!
        @name = ANY
      end

      def build!(filter)
        raise NotImplementedError
      end
    end

    class Application < Common
      def initialize(name = nil, *event_types)
        super(name)
        event_types.each { |type| self.event_type type }
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
        if @name == ANY
          filter.app_filters.create
        else
          app = ::App.find_by(:name => @name)
          filter.apps << app
          @children.each { |builder| builder.build!(filter, app) }
        end
      end
    end

    class EventType < Common
      def build!(filter, app)
        if @name == ANY
          filter.event_type_filters.create
        else
          filter.event_types << app.event_types.where(:name => @name).first
          @children.each { |builder| builder.build!(filter) }
        end
      end
    end

    class Severity < Common
      alias severity name

      def build!(filter)
        if @name == ANY
          filter.severity_filters.create
        else
          filter.severity_filters.create(:severity => @name)
        end
      end
    end
  end
end
