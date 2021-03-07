# Drupal APIs

http://localhost/api/drupal

## How it builds

- Every minute a cronjob processes tasks out of a queue.
- Every 15 mins the cron task runs and pumps more shit into that queue.
- After a few hours its built. 

## Build

`docker-compose up --build`

Startup can take about 5 minutes.

## Check build status

`docker-compose exec web drush api-count-queues`

## Nuke

`docker-compose down -v`

## Adding more versions

Add the repo to the `.docker/web.entrypoint.sh`, BRANCHES array. Nuke and repeat.

## Admin login

http://localhost/user

- admin
- password