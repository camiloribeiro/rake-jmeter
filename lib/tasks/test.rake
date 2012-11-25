namespace :test do
  desc "Run all the tests :D"
  task :all do
    system("rspec test/virtual_machines.spec --format NyanCatFormatter --color")
  end
end
