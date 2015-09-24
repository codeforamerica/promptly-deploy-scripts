# Somerville Student Insights Deployment Scripts

- Ubuntu 14
- 1GB RAM minimum

```shell
sudo apt-get install -y git
git clone -b somerville-v1 https://github.com/daguar/promptly-deploy-scripts.git
cd promptly-deploy-scripts
bash setup_student_insights.sh
bash test_web_server_with_psql.sh
```
