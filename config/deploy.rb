#load "deploy/assets"
#load 'lib/deploy/assets'

# replace these with your server's information
set :domain,  "vonneumann.avante.com"
set :user,    "deploy"

# name this the same thing as the directory on your server
set :application, "blog"

# use your local repository as the source
set :repository, "git@github.com:bertoaboud/blog2.git"

# or use a hosted repository
#set :repository, "ssh://user@example.com/~/git/test.git"

server "#{domain}", :app, :web, :db, :primary => true

set :deploy_via, :copy
set :copy_exclude, [".git", ".DS_Store"]
set :scm, :git
set :branch, "master"
# set this path to be correct on yoru server
set :deploy_to, "/home/#{user}/#{application}"
set :use_sudo, false
set :keep_releases, 2
set :git_shallow_clone, 1

ssh_options[:paranoid] = false

require "rvm/capistrano"
require "bundler/capistrano"

# this tells capistrano what to do when you deploy
namespace :deploy do
  desc <<-DESC
  A macro-task that updates the code and fixes the symlink.
  DESC
  task :default do
    transaction do
      update_code
      symlink
    end
  end
  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    strategy.deploy!
    run "echo === Rake Setup=== && cd #{latest_release} && rake db:create RAILS_ENV=production && rake db:migrate RAILS_ENV=production"
  end
  task :after_deploy do
#    cleanup
  end
end

#restart APACHE
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "/etc/init.d/apache2 #{action.to_s}", :via => run_method
    end
  end
end


namespace :deploy do
  namespace :assets do
 
    def not_first_deploy?
      'true' ==  capture("if [ -e #{current_path}/REVISION ]; then echo 'true'; fi").strip
    end
 
    desc "Run the asset precompilation rake task only if there are changes."
    task :precompile, :roles => :web, :except => { :no_release => true } do
      if not_first_deploy?
        from = source.next_revision(current_revision)
        if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
        else
          logger.info "Skipping asset pre-compilation because there were no asset changes"
        end
      end
    end
 
  end
end


namespace :deploy do
  task :bundle do
    run "cd #{latest_release} && bundle install --deployment --without development test staging"
  end
end

after "deploy", "deploy:assets:precompile"
