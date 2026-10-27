module Lograge
  module Formatters
    class Dev
      COLORS = {
        green:  "\e[32m",
        yellow: "\e[33m",
        red:    "\e[31m",
        cyan:   "\e[36m",
        gray:   "\e[90m",
        bold:   "\e[1m",
        reset:  "\e[0m"
      }.freeze

      STATUS_COLOR = ->(s) {
        case s
        when 200..299 then COLORS[:green]
        when 300..399 then COLORS[:cyan]
        when 400..499 then COLORS[:yellow]
        when 500..599 then COLORS[:red]
        else               COLORS[:reset]
        end
      }

      METHOD_COLOR = ->(m) {
        case m
        when "GET"    then COLORS[:gray]
        when "POST"   then COLORS[:green]
        when "PATCH",
             "PUT"    then COLORS[:yellow]
        when "DELETE" then COLORS[:red]
        else               COLORS[:reset]
        end
      }

      def call(data)
        g  = COLORS[:gray]
        r  = COLORS[:reset]
        b  = COLORS[:bold]
        sc = STATUS_COLOR.call(data[:status])
        mc = METHOD_COLOR.call(data[:method])

        parts = [
          "#{mc}#{b}#{data[:method].ljust(6)}#{r}",
          "#{data[:path]}",
          "#{sc}#{b}#{data[:status]}#{r}",
          "#{g}#{data[:duration].round}ms#{r}"
        ]

        parts << "#{COLORS[:red]}err=#{data[:error]}#{r}" if data[:error]

        parts.join("  ")
      end
    end
  end
end

ActiveModelSerializers.logger = Logger.new(nil)

Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.formatter = if Rails.env.production?
    Lograge::Formatters::Json.new
  else
    Lograge::Formatters::Dev.new
  end

  config.lograge.custom_options = lambda do |event|
    options = {}
    options[:request_id] = event.payload[:request_id]       if event.payload[:request_id]
    options[:error]      = event.payload[:exception_object]&.message
    options.compact
  end
end
