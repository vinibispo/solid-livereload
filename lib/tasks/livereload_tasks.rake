namespace :livereload do
  desc "Install Solid::Livereload into the app"
  task :install do
    system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/install.rb", __dir__)}"
  end

  desc "Disable Solid::Livereload"
  task :disable do
    FileUtils.mkdir_p("tmp")
    FileUtils.touch Solid::Livereload::DISABLE_FILE
    puts "Livereload disabled."
  end

  desc "Enable Solid::Livereload"
  task :enable do
    if File.exist?(Solid::Livereload::DISABLE_FILE)
      File.delete Solid::Livereload::DISABLE_FILE
    end
    puts "Livereload enabled."
  end
end
