# Promptly Deployment Scripts

These instructions (and included scripts) streamline deploying [Promptly](https://github.com/codeforamerica/promptly) onto an Ubuntu server, specifically:

- Ubuntu 14
- 1GB RAM minimum


### Step 1 (Manual): Create a new user `somervillain` with sudo and log into it

Create a new user `somervillain` by using the below commands; give the user a password and write it down.

```shell
adduser somervillain --gecos "" --ingroup sudo
su somervillain
cd ~
```

### Step 2 (Manual): Get setup scripts from GitHub
```shell
sudo apt-get install -y git
git clone https://github.com/daguar/promptly-deploy-scripts.git
cd promptly-deploy-scripts
# Switch to Somerville branch!
```

### Step 3 (Manual): Configure the deployment variables

On the server, edit the `promptly_deploy_config.conf` file, replacing the dummy data there with the specific configuration variables (like Twilio phone number) for your deploy.

(Dummy data is provided in case you are simply trying out out these deploy scripts.)


### Step 4 (Scripted): Run setup script

Run the below command; it will ask you for the `promptly` user's password a few times (type it in and hit enter) and also ask you to hit enter to continue a few times.

```shell
bash setup_promptly.sh
```

(This script should take 5-15 minutes to run.)


### Step 5 (Scripted): Test the web server with a dummy database

Now we'll run a script to set up a dummy database (using SQLite) to make sure that the web server and app is working.

```shell
cd ~/promptly-deploy-scripts
bash test_web_server_with_sqlite_database.sh
```

(This script should take about 3-6 minutes to run.)

You should now be able to visit the IP of the server in a browser and view the Promptly deploy, e.g. http://10.0.0.2/


### Step 6 (Manual): Configure production database connection

The setup script will set up a SQLite database to test that the web server is working. You will need to manually configure `/home/promptly/promptly/config/database.yml` on the server with your own database connection details.

After that, you will need to re-run a few steps in the script:

```shell
rake db:schema:load
rake db:seed
rake assets:precompile

sudo service apache2 restart
```
