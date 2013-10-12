require 'rack'

module WhippedCream
  # A server handles building a plugin/runner and starting a web server
  class Server
    attr_reader :plugin

    def initialize(plugin)
      @plugin = plugin
    end

    def start(options = {})
      ensure_routes_built
      ensure_runner_started

      start_web(options)
    end

    def runner
      @runner ||= Runner.create_instance(plugin)
    end

    def port
      8080
    end

    def web
      @web ||= Web
    end

    private

    def ensure_runner_started
      runner
    end

    def ensure_routes_built
      @routes_built ||= build_routes || true
    end

    def start_web(options = {})
      options = { app: web, port: port }.merge(options)

      Rack::Server.start options
    end

    def build_routes
      build_button_routes
      build_switch_routes
    end

    def build_button_routes
      plugin.buttons.each do |button|
        web.get "/#{button.id}" do
          runner.send(button.id)
          redirect to('/')
        end
      end
    end

    def build_switch_routes
      plugin.switches.each do |switch|
        web.get "/#{switch.id}" do |value|
          runner.send("#{switch.id}=", value)
          redirect to('/')
        end
      end
    end
  end
end
