# Drupal APIs

A local version of the Drupal API for consumption by scraping tools.

> Check out https://kapeli.com/dash and https://zealdocs.org/

## How it builds

- Boot: Run cron job and queue up API processing.
- Every minute a cronjob processes about 500 tasks out of a queue.
- After initial processing it builds class relations.

---

## 1. Build

`docker-compose up --build -d`

Startup can take up to 5 minutes depending on server size.

## 2. Check build status

`docker-compose exec web drush api:count-queues`

If there is only 1 task remainnig, it's going to be the class relations task. **You need to wait.**

## 3. After build

Important: Clear the Drupal cache and stop the cron runner.

- `docker-compose exec web drush cr`
- `docker-compose stop cron`
- http://localhost/api/drupal

---

## Deploying on linode

- Ubuntu 20 or whatever flavour you're good with.
- 2cpu 4gb ram minimum. More CPU better.

```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.28.5/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

## Nuke

`docker-compose down -v`

## Changing the API version

Change the `BRANCH` variable in `.docker/web.entrypoint.sh`. Nuke docker and repeat.

## Admin login

http://localhost/user

- admin
- password
