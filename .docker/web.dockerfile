FROM composer:1 AS composer-version
FROM drupal:7-apache

VOLUME /var/www/html/code
VOLUME /var/www/html/sites

# Env for docker-compose
ENV REPO_DIR=/var/www/html/code
ENV APACHE_DOCUMENT_ROOT=/var/www/html

# Install git and some deps
RUN apt update && apt install -y -qq git curl wget tar zip unzip gzip mariadb-client && rm -r /var/lib/apt/lists/*
RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

# Install composer
COPY --from=composer-version /usr/bin/composer /usr/bin/composer
RUN export PATH="$HOME/.composer/vendor/bin:$PATH"

# Speed up composer 1
RUN composer global require hirak/prestissimo

# Install Drush
RUN curl -L https://github.com/drush-ops/drush/releases/download/8.4.6/drush.phar --output /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush
RUN drush init -y

# Prep settings
RUN mkdir -p $REPO_DIR
COPY modules /tmp/modules

# Copy defaults to tmp for copyback on install
RUN cp -Rp $APACHE_DOCUMENT_ROOT/sites /tmp/sites

# Install Drupal script
COPY .docker/web.entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh