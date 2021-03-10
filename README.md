# Drupal APIs

http://localhost/api/drupal

## How it builds

- Every minute a cronjob processes tasks out of a queue.
- Every 15 mins the cron task runs and pumps more shit into that queue.
- After a few hours its built. 

## 1. Build

`docker-compose up --build -d`

Startup can take about 5 minutes.

## 2. Check build status

`docker-compose exec web drush api-count-queues`

## 3. After build

Clear the drupal cache and stop the cron runner.

- `docker-compose exec web drush cc all`
- `docker-compose stop cron`

## Deploying on linode

- Ubuntu 20 or whatever flavour you're good with.
- 2cpu 4gb ram minimum. More CPU better.
- https://www.linode.com/docs/guides/how-to-use-docker-compose/

Once you get to the step for 'Install Docker Compose' make sure you use the at least version `1.28.5`. The command would be.

    sudo curl -L https://github.com/docker/compose/releases/download/1.28.5/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

Otherwise it wont start.

## Nuke

`docker-compose down -v`

## Adding more versions

Add the repo to the `.docker/web.entrypoint.sh`, BRANCHES array. Nuke and repeat.

## Admin login

http://localhost/user

- admin
- password
