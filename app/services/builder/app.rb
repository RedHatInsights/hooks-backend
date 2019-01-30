# frozen_string_literal: true

module Builder
  class App
    def event_types
      @event_types ||= []
    end

    def event_type(name)
      @event_types ||= []
      @event_types << name
    end

    def name(name)
      @name = name
    end

    def build!
      app = ::App.new(:name => @name)
      app.save!
      event_types.each do |type|
        app.event_types.create(:name => type)
      end
      app
    end

    def self.build!
      builder = App.new
      yield builder
      builder.build!
    end
  end
end
