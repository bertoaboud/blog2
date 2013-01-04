#----------------------------------------------------
# replace these with your server's information
set :domain,  "vonneumann.avante.com"
set :user,    "deploy"

set :application, "blog"
set :repository, "git@github.com:bertoaboud/blog2.git"

server "#{domain}", :app, :web, :db, :primary => true

set :deploy_via, :copy
set :copy_exclude, [".git", ".DS_Store"]
set :scm, :git
set :branch, "master"

set :deploy_to, "/home/#{user}/#{application}"
set :use_sudo, false
set :keep_releases, 2
set :git_shallow_clone, 1

ssh_options[:paranoid] = false
#----------------------------------------------------

require "rvm/capistrano"
require "bundler/capistrano"

set :normalize_asset_timestamps, false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#  end
end

after "deploy:assets:precompile", "db:create"

namespace :db do
  desc "Create Production Database"
  task :create do
    puts "\n\n=== Creating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:create RAILS_ENV=production"
    system "cap deploy:set_permissions"
  end
  
  desc "Migrate Production Database"
  task :migrate do
    puts "\n\n=== Migrating the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:migrate RAILS_ENV=production"
    system "cap deploy:set_permissions"
  end
 
  desc "Resets the Production Database"
  task :migrate_reset do
    puts "\n\n=== Resetting the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:migrate:reset RAILS_ENV=production"
  end
    
  desc "Destroys Production Database"
  task :drop do
    puts "\n\n=== Destroying the Production Database! ===\n\n"
    run "cd #{current_path}; rake db:drop RAILS_ENV=production"
    system "cap deploy:set_permissions"
  end
end


      namespace :assets do
        task :precompile, :roles => :web, :except => { :no_release => true } do
          from = source.next_revision(current_revision)
          if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
            run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
          else
            logger.info "Skipping asset pre-compilation because there were no asset changes"
          end
      end
    end
 
#namespace :aft_deploy do
#  run "echo === Rake Setup=== && cd #{latest_release} && bundle exec rake db:setup RAILS_ENV=production"
#end

#after "deploy", "after_deploy"
