#!/bin/bash

# Set up Postgres db and user
sudo -u postgres createuser ubuntu -s
createdb student_insights_production

source ~/.rvm/scripts/rvm

echo "production:
  adapter: postgresql
  encoding: unicode
  pool: 5
  database: student_insights_production
  username: ubuntu
  password:
" | sudo tee /home/ubuntu/somerville-teacher-tool/config/database.yml

export RAKE_ENV=production
export RAILS_ENV=production
export SECRET_TOKEN=fakefakefakefakefakefakefakefakefakefakefakefakefakefakefakefakefakefake

cd /home/ubuntu/somerville-teacher-tool

rake db:schema:load
rake db:seed:demo
rake assets:precompile

sudo service apache2 restart
