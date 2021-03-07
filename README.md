# Drupal APIs

http://localhost/api/drupal

## How it builds

- Every minute a cronjob processes tasks out of a queue.
- Every 15 mins the cron task runs and pumps more shit into that queue.
- After a few hours its built. 
- Once built, should see "Processed 0 items from the api_parse queue in 0 sec." in cron log.

## Build

`docker-compose up --build`

Startup can take about 5 minutes.

## Nuke

`docker-compose down -v`

## Adding more versions

Add the repo to the `.docker/web.entrypoint.sh`, git, composer and drush commands. Nuke and repeat.

## Admin login

http://localhost/user

- admin
- password