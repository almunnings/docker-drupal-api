FROM docker-drupal-api:latest

RUN apt update && apt -y install -qq cron && rm -r /var/lib/apt/lists/*

ADD .docker/crontab /etc/cron.d/drush-cron
RUN chmod a+x /etc/cron.d/drush-cron
RUN crontab /etc/cron.d/drush-cron

RUN touch /etc/crontab /etc/cron.*/*

CMD ["cron", "-f"]