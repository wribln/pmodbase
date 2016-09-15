#lib/tasks/custom_seed.rake
desc 'Perform seed using a specific file'
# usage: rake db:seed:<filename w/o .rb> [<project>]
namespace :db do
  namespace :seed do
    Dir[ File.join(Rails.root, 'db', 'seeds', '*.rb' )].each do |filename|
      task_name = File.basename( filename, '.rb' ).to_sym
      task task_name, [ :project ] => :environment do |t, args|
        @project = args[ :project ]
        load( filename ) if File.exist?( filename )
      end
    end
  end
end