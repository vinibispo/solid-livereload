module Solid::Livereload::LivereloadTagsHelper
  def solid_livereload_tags
    partial = if Solid::Livereload::Engine.config.solid_livereload.reload_method == :turbo_stream
      "solid/livereload/head_turbo_stream"
    else
      "solid/livereload/head_action_cable"
    end

    render partial
  end
end
