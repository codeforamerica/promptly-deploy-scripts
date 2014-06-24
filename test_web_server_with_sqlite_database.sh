#!/bin/bash
# We'll use a temp SQLite database setup to test the web server setup in isolation

source ~/.rvm/scripts/rvm

echo "production:
  adapter: sqlite3
  database: db/production.sqlite3
  pool: 5
  timeout: 5000" | sudo tee /home/promptly/promptly/config/database.yml

export RAKE_ENV=production
export RAILS_ENV=production
export SECRET_TOKEN=fakefakefakefakefakefakefakefakefakefakefakefakefakefakefakefakefakefake

cd /home/promptly/promptly

rake db:schema:load
rake db:seed
rake assets:precompile

sudo service apache2 restart
