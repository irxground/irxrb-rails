# desc "Explaining what the task does"
# task :irxrb-rails do
#   # Task goes here
# end

namespace :db do
  namespace :migrate do
    desc 'migrate sql views'
    task :views do
      puts "HELLO"
    end
  end
end
