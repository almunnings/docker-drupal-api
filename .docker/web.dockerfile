FROM drupal:7-apache

VOLUME /var/www/html/code
VOLUME /var/www/html/sites

# Env for docker-compose
ENV REPO_DIR=/var/www/html/code
ENV APACHE_DOCUMENT_ROOT=/var/www/html

# Copy install requirements
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY modules /tmp/modules
COPY .docker/web.entrypoint.sh /entrypoint.sh

# All run actions in one layer.
RUN apt update && apt install -y -qq git curl wget tar zip unzip gzip mariadb-client && \
  rm -r /var/lib/apt/lists/* && \
  echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini && \
  export PATH="$HOME/.composer/vendor/bin:$PATH" && \
  curl -L https://github.com/drush-ops/drush/releases/download/8.4.11/drush.phar --output /usr/local/bin/drush && \
  chmod +x /usr/local/bin/drush && \
  drush init -y && \
  mkdir -p $REPO_DIR && \
  cp -Rp $APACHE_DOCUMENT_ROOT/sites /tmp/sites && \
  chmod +x /entrypoint.sh

CMD /entrypoint.sh