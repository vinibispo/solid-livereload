require "rails"
require "action_cable/engine"
require "listen"

module Solid
  module Livereload
    class Engine < ::Rails::Engine
      isolate_namespace Solid::Livereload
      config.solid_livereload = ActiveSupport::OrderedOptions.new
      config.solid_livereload.listen_paths ||= []
      config.solid_livereload.skip_listen_paths ||= []
      config.solid_livereload.force_reload_paths ||= []
      config.solid_livereload.reload_method = :action_cable
      config.solid_livereload.disable_default_listeners = false
      config.autoload_once_paths = %W[
        #{root}/app/channels
        #{root}/app/helpers
      ]
      config.solid_livereload.listen_options ||= {}
      config.solid_livereload.debounce_delay_ms = 0

      initializer "solid_livereload.assets" do
        if Rails.application.config.respond_to?(:assets)
          Rails.application.config.assets.precompile += %w[solid-livereload.js solid-livereload-turbo-stream.js]
        end
      end

      initializer "solid_livereload.helpers" do
        ActiveSupport.on_load(:action_controller_base) do
          helper Solid::Livereload::LivereloadTagsHelper
        end
      end

      initializer "solid_livereload.set_configs" do |app|
        options = app.config.solid_livereload
        skip_listen_paths = options.skip_listen_paths.map(&:to_s).uniq

        unless options.disable_default_listeners
          default_listen_paths = %w[
            app/views
            app/helpers
            app/javascript
            app/assets/stylesheets
            app/assets/javascripts
            app/assets/images
            app/components
            config/locales
          ]
          if defined?(Jsbundling)
            default_listen_paths -= %w[app/javascript]
            default_listen_paths += %w[app/assets/builds]
          end
          if defined?(Cssbundling)
            default_listen_paths -= %w[app/assets/stylesheets]
            default_listen_paths += %w[app/assets/builds]
          end
          options.listen_paths += default_listen_paths
            .uniq
            .map { |p| Rails.root.join(p) }
            .select { |p| Dir.exist?(p) }
            .reject { |p| skip_listen_paths.include?(p.to_s) }
        end
      end

      config.after_initialize do |app|
        if Rails.env.development? && Solid::Livereload.server_process?
          @trigger_reload = (Solid::Livereload.debounce(config.solid_livereload.debounce_delay_ms) do |options|
            if config.solid_livereload.reload_method == :turbo_stream
              Solid::Livereload.turbo_stream(options)
            else
              Solid::Livereload.action_cable(options)
            end
          end)

          options = app.config.solid_livereload
          listen_paths = options.listen_paths.map(&:to_s).uniq
          force_reload_paths = options.force_reload_paths.map(&:to_s).uniq.join("|")

          @listener = Listen.to(*listen_paths, **config.solid_livereload.listen_options) do |modified, added, removed|
            unless File.exist?(DISABLE_FILE)
              changed = [modified, removed, added].flatten.uniq
              next unless changed.any?

              force_reload = force_reload_paths.present? && changed.any? do |path|
                path.match(%r{#{force_reload_paths}})
              end

              options = {changed: changed, force_reload: force_reload}
              @trigger_reload.call(options)
            end
          end
          @listener.start
        end
      end

      at_exit do
        if Rails.env.development?
          @listener&.stop
        end
      end
    end

    def self.turbo_stream(locals)
      Turbo::StreamsChannel.broadcast_replace_to(
        "solid-livereload",
        target: "solid-livereload",
        partial: "solid/livereload/turbo_stream",
        locals: locals
      )
    end

    def self.action_cable(opts)
      ActionCable.server.broadcast("solid-reload", opts)
    end

    def self.server_process?
      puma_process = defined?(::Puma) && File.basename($0) == "puma"
      rails_server = defined?(Rails::Server)

      puma_process || rails_server
    end

    def self.debounce(wait_ms, &block)
      if wait_ms.zero?
        return ->(*args) { yield(*args) }
      end

      mutex = Mutex.new
      timer_thread = nil
      seconds = wait_ms.to_f / 1000.0

      lambda do |*args|
        mutex.synchronize do
          # Cancel previous timer
          timer_thread&.kill

          timer_thread = Thread.new do
            sleep(seconds)
            yield(*args)
          end
        end
      end
    end
  end
end
