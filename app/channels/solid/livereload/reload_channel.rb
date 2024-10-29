class Solid::Livereload::ReloadChannel < ActionCable::Channel::Base
  def subscribed
    stream_from "solid-reload"
  end
end
