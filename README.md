# Promptly Deployment Scripts

This repository includes instructions and a script to automate most of the process of deploying Promptly onto an Ubuntu server (12.04.4 Long Term Support [LTS] release).

### STEP 1 (Manual): The redeployer creates a new user `promptly` with sudo and log into it

```shell
#Create a promptly user (if it doesn’t exist)
sudo adduser promptly
sudo adduser promptly sudo
su promptly
cd ~
```

### STEP 2 (Manual): Get setup script from GitHub (irrelevant for now)
```shell
# Eventually use this process for getting and running the setup script
sudo apt-get install -y git
git clone https://github.com/daguar/promptly-deploy-scripts.git  # or wherever
cd promptly-deploy-scripts
```

### STEP 3 (Manual): Configure the deployment variables
```
# Open the promptly_deploy_config.conf file and add the desired values at the end
```

### Step 4 (Scripted): Run setup script
`bash setup_promptly.sh`


### Step 5 (Scripted): Test the web server with a dummy database

Now we'll run a script to set up a dummy database (using SQLite) to make sure that the web server and app is working.

```shell
cd ~/promptly-deploy-scripts
bash test_web_server_with_sqlite_database.sh
```

You should now be able to visit the IP of the server in a browser and view the Promptly deploy, e.g. http://10.0.0.2/

### Step 5 (Manual): Configure production database connection
The setup script will set up a SQLite database to test that the web server is working. You will need to manually configure `/home/promptly/promptly/config/database.yml` on the server with your own database connection details.

After that, you will need to re-run a few steps in the script:

```shell
rake db:schema:load
rake db:seed
rake assets:precompile

sudo service apache2 restart
```
