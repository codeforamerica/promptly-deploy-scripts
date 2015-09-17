source promptly_deploy_config.conf # Get our deploy-specific variables
# May want to raise an error and stop script if any necessary variables are blank

sudo apt-get update
sudo apt-get install -y curl git
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -L https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm
rvm install 2.1.6 #hard-coded, could variable-ize
rvm --default use 2.1.6
sudo apt-get install -y apache2 libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev freetds-dev #apache-2-mpm-worker (was not working)

gem install passenger -v 4.0.45 #hard-coded, could variable-ize

passenger-install-apache2-module --languages ruby --auto

### Have hard-coded the below per Ruby & Passenger gem versions specified above
sudo touch /etc/apache2/mods-available/passenger.load
echo "LoadModule passenger_module /home/somervillain/.rvm/gems/ruby-2.1.6/gems/passenger-4.0.45/buildout/apache2/mod_passenger.so" | sudo tee /etc/apache2/mods-available/passenger.load
sudo touch /etc/apache2/mods-available/passenger.conf
echo "PassengerRoot /home/somervillain/.rvm/gems/ruby-2.1.6/gems/passenger-4.0.45
PassengerDefaultRuby /home/somervillain/.rvm/gems/ruby-2.1.6/wrappers/ruby" | sudo tee /etc/apache2/mods-available/passenger.conf

sudo a2enmod passenger

sudo touch /etc/apache2/sites-enabled/somerville-teacher-tool
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
    ServerName somervillain

    # Identify the root application directory
    # Docs: http://httpd.apache.org/docs/2.2/mod/core.html#documentroot
    DocumentRoot /home/somervillain/somerville-teacher-tool/public

    # Include some directives for the promptly directory (Details: http://httpd.apache.org/docs/2.2/mod/core.html#directory)
    <Directory /home/somervillain/somerville-teacher-tool/public>
            Allow from all
            Options -MultiViews
    </Directory>
</VirtualHost>" | sudo tee /etc/apache2/sites-enabled/somerville-teacher-tool

echo "RAILS_ENV=production
RACK_ENV=production" | sudo tee -a /etc/environment

sudo rm /etc/apache2/sites-enabled/000-default #removing the default apache site

cd ~
# Will change when the stable deploy branch is determined
git clone https://github.com/codeforamerica/somerville-teacher-tool.git
sudo chown -R somervillain somerville-teacher-tool/ #necessary for asset precompilation
cd somerville-teacher-tool

source ~/.rvm/scripts/rvm # Just in case something went wrong and we don't have rvm loaded
bundle install
