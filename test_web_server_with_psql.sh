#!/bin/bash

# Set up Postgres db and user
sudo -u postgres createuser ubuntu -s
createdb student_insights_production

# Configure passwordless postgres for testing
echo "# Database administrative login by Unix domain socket
local   all             all                                     trust

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
" | sudo tee /etc/postgresql/9.3/main/pg_hba.conf

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

source ~/.rvm/scripts/rvm
sudo service apache2 restart
