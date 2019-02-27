# flask-boilerplate

1. Change vars at deploy/tasks/ main.yml and base.yml
1. Change domain at deploy/inventory/ dev and staging
1. Create s3 bucket and ecr repo
1. At the Makefile change S3_BUCKET and ECR_REPO_URL vars
1. Run `make -f Makefile-setup setup APP_NAME=YOUR_APP_NAME`
1. copy pem key to server access to ./secrets/server.pem
1. to ./secrets/dev/.env add ./secrets/staging/.env add vars AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
1. `make push_secrets ENV=dev`
1. `make push_secrets ENV=staging`
1. Run `git remote add origin *******`
