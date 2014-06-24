source promptly_deploy_config.conf # Get our deploy-specific variables
# May want to raise an error and stop script if any necessary variables are blank

sudo apt-get update
sudo apt-get install -y curl
curl -L https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm
rvm install 2.1.2 #hard-coded, could variable-ize
rvm --default use 2.1.2
sudo apt-get install -y apache2 libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev freetds-dev apache-2-mpm-worker

gem install passenger -v 4.0.45 #hard-coded, could variable-ize

passenger-install-apache2-module

### Have hard-coded the below per Ruby & Passenger gem versions specified above
sudo touch /etc/apache2/mods-available/passenger.load
echo "LoadModule passenger_module /home/promptly/.rvm/gems/ruby-2.1.2/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so" | sudo tee /etc/apache2/mods-available/passenger.load
sudo touch /etc/apache2/mods-available/passenger.conf
echo "PassengerRoot /home/promptly/.rvm/gems/ruby-2.1.2/gems/passenger-4.0.45
PassengerDefaultRuby /home/promptly/.rvm/gems/ruby-2.1.2/wrappers/ruby" | sudo tee /etc/apache2/mods-available/passenger.conf

sudo a2enmod passenger

sudo touch /etc/apache2/sites-enabled/promptly
echo "SetEnv RAILS_ENV production
SetEnv RACK_ENV production
SetEnv TWILIO_NUMBER $SCRIPT_TWILIO_NUMBER
SetEnv TWILIO_SID $SCRIPT_TWILIO_SID
SetEnv TWILIO_TOKEN $SCRIPT_TWILIO_TOKEN
SetEnv SECRET_TOKEN $SCRIPT_SECRET_TOKEN

# Standard apache config
<VirtualHost *:80>
    # Set Passenger user to root
    PassengerUserSwitching on
    PassengerUser root
    PassengerDefaultUser root

    # Identify the web server
    # Docs: http://httpd.apache.org/docs/2.2/mod/core.html#servername
    ServerName promptly

    # Identify the root application directory
    # Docs: http://httpd.apache.org/docs/2.2/mod/core.html#documentroot
    DocumentRoot /home/promptly/promptly/public #note this is standard

    # Include some directives for the promptly directory (Details: http://httpd.apache.org/docs/2.2/mod/core.html#directory)
    <Directory /home/promptly/promptly/public>
            Allow from all
            Options -MultiViews
    </Directory>
</VirtualHost>" | sudo tee /etc/apache2/sites-enabled/promptly

echo "RAILS_ENV=production
RACK_ENV=production
TWILIO_NUMBER=$SCRIPT_TWILIO_NUMBER
TWILIO_SID=$SCRIPT_TWILIO_SID
TWILIO_TOKEN=$SCRIPT_TWILIO_TOKEN
SECRET_TOKEN=$SCRIPT_SECRET_TOKEN" | sudo tee -a /etc/environment

sudo rm /etc/apache2/sites-enabled/000-default #removing the default apache site

cd ~
git clone https://github.com/postcode/promptly.git
sudo chown -R promptly promptly/ #necessary for asset precompilation
cd promptly
source ~/.rvm/scripts/rvm # Just in case something went wrong and we don't have rvm loaded
bundle install

# We'll use a temp SQLite database setup to test the web server setup in isolation
# All steps after this will have to be repeated when you configure the hard database connection
echo "production:
  adapter: sqlite3
  database: db/production.sqlite3
  pool: 5
  timeout: 5000" | sudo echo tee ~/promptly/promptly/config/database.yml

rake db:schema:load
rake db:seed
rake assets:precompile

sudo service apache2 restart
