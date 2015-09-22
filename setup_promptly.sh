RUBY_VERSION="2.2.3"

source promptly_deploy_config.conf # Get our deploy-specific variables
# May want to raise an error and stop script if any necessary variables are blank

sudo apt-get update
sudo apt-get install -y curl
curl -L https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm
rvm install $RUBY_VERSION
rvm --default use $RUBY_VERSION
sudo apt-get install -y apache2 libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev freetds-dev #apache-2-mpm-worker (was not working)

gem install passenger -v 4.0.45 #hard-coded, could variable-ize

passenger-install-apache2-module --languages ruby --auto

### Have hard-coded the below per Ruby & Passenger gem versions specified above
sudo touch /etc/apache2/mods-available/passenger.load
echo "LoadModule passenger_module /home/gcf/.rvm/gems/ruby-${RUBY_VERSION}/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so" | sudo tee /etc/apache2/mods-available/passenger.load
sudo touch /etc/apache2/mods-available/passenger.conf
echo "PassengerRoot /home/gcf/.rvm/gems/ruby-${RUBY_VERSION}/gems/passenger-4.0.45
PassengerDefaultRuby /home/gcf/.rvm/gems/ruby-${RUBY_VERSION}/wrappers/ruby" | sudo tee /etc/apache2/mods-available/passenger.conf

sudo a2enmod passenger

sudo touch /etc/apache2/sites-enabled/gcf-backend
echo "SetEnv RAILS_ENV production
SetEnv RACK_ENV production

# Standard apache config
<VirtualHost *:80>
    # Set Passenger user to root
    PassengerUserSwitching on
    PassengerUser root
    PassengerDefaultUser root

    # Identify the web server
    # Docs: http://httpd.apache.org/docs/2.2/mod/core.html#servername
    ServerName gcf

    # Identify the root application directory
    # Docs: http://httpd.apache.org/docs/2.2/mod/core.html#documentroot
    DocumentRoot /home/gcf/gcf-backend/public

    # Include some directives for the promptly directory (Details: http://httpd.apache.org/docs/2.2/mod/core.html#directory)
    <Directory /home/gcf/gcf-backend/public>
            Allow from all
            Options -MultiViews
    </Directory>
</VirtualHost>" | sudo tee /etc/apache2/sites-enabled/gcf-backend

echo "RAILS_ENV=production
RACK_ENV=production" | sudo tee -a /etc/environment

sudo rm /etc/apache2/sites-enabled/000-default #removing the default apache site

#cd ~
# Will change when the stable deploy branch is determined
#git clone https://github.com/codeforamerica/gcf-backend.git
#sudo chown -R gcf gcf-backend/ #necessary for asset precompilation
#cd gcf-backend

#source ~/.rvm/scripts/rvm # Just in case something went wrong and we don't have rvm loaded
#bundle install
