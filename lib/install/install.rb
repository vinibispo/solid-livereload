APP_LAYOUT_PATH = Rails.root.join("app/views/layouts/application.html.erb")
CABLE_CONFIG_PATH = Rails.root.join("config/cable.yml")

if APP_LAYOUT_PATH.exist?
  say "Add Solid Livereload tag in application layout"
  content = <<~HTML
    \n    <%= solid_livereload_tags if Rails.env.development? %>
  HTML
  insert_into_file APP_LAYOUT_PATH, content.chop, before: /\s*<\/head>/
else
  say "Default application.html.erb is missing!", :red
  say %(  Add <%= solid_livereload_tags %> within the <head> tag in your custom layout.)
  say %(  If using `config.solid_livereload.reload_method = :turbo_stream`, place *after* the `<%= action_cable_meta_tag %>`.)
end

if CABLE_CONFIG_PATH.exist?
  gemfile = File.read(Rails.root.join("Gemfile"))
  if gemfile.include?("solid_cable")
    say "Uncomment solid_cable in Gemfile"
    uncomment_lines "Gemfile", %r{gem ['"]solid_cable['"]}
  else
    say "Add redis to Gemfile"
    gem "solid_cable"
  end

  say "Switch development cable to use solid_cable"
  gsub_file CABLE_CONFIG_PATH.to_s, /development:\n\s+adapter: async/, "development:\n\s+adapter: solid_cable\n\s+connects_to:\n\s+database:\n\s+writing: cable"
else
  say 'ActionCable config file (config/cable.yml) is missing. Uncomment "gem \'solid_cable\'" in your Gemfile and create config/cable.yml to use Solid Livereload.'
end
