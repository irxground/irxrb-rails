namespace :db do
  namespace :views do
    desc 'Drop All DB Views'
    task :drop => [:environment]do
      Irxrb::Rails::DBViewMigrator.drop_all
    end

    desc 'Migrate DB Views'
    task :migrate => [:environment] do
      Irxrb::Rails::DBViewMigrator.migrate
    end
  end

  # add hook
  task :migrate => 'db:views:drop' do
    Rake::Task['db:views:migrate'].invoke
  end
  namespace :test do
    task :prepare => 'db:views:drop' do
      Rake::Task['db:views:migrate'].invoke
    end
  end
end

