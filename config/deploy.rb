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

 #set :default_environment, {
 #  'GEM_HOME'     => '/home/deploy/.rvm/gems/ruby-1.9.3-p327',
 #  'GEM_PATH'     => '/home/deploy/.rvm/gems/ruby-1.9.3-p327',
 #  'BUNDLE_PATH'  => '/home/deploy/.rvm/gems/ruby-1.9.3-p327'
 #}

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :after_deploy do
  run "echo === Rake Setup=== && cd #{latest_release} && bundle exec rake db:setup RAILS_ENV=production"
end

after "deploy:restart", "after_deploy"
