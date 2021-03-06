# Drupal APIs

http://localhost/api/drupal

## How it builds

- Every minute a cronjob processes tasks out of a queue.
- Every 15 mins the cron task runs and pumps more shit into that queue.
- After a few hours its built.

## Build

`docker-compose up --build`

Startup can take about 5 minutes. First cron task take a while to queue everything up.

Takes about an hour to process all the APIs via the CRON tasks.

## Nuke

`docker-compose down -v`

## Adding more versions

Add the repo to the `web.entrypoing.sh`, git and drush command. Nuke and repeat.

## Admin login

http://localhost/user

- admin
- password