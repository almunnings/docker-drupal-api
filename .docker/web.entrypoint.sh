#!/bin/sh

cd $APACHE_DOCUMENT_ROOT

echo "Downloading repos..."


# Check if already installed.
if [ ! -f "$APACHE_DOCUMENT_ROOT/sites/default/settings.php" ]; then

    echo "Copying structure..."

    # Prep dir structure, as we've made it a volume.
    cp -Rp /tmp/sites $APACHE_DOCUMENT_ROOT
    chown -R www-data:www-data $APACHE_DOCUMENT_ROOT/sites

    # Give the database some time to start up.
    echo "Waiting for database..."
    sleep 10

    # Install Drupal
    drush si -y standard --db-url=mysql://root:root@mysql/drupal

    # Install custom modules from tar
    tar -C $APACHE_DOCUMENT_ROOT/sites/all/modules -xvf /tmp/modules/*.tar

    # Install contrib nodules.
    drush dl -y composer_manager
    drush en -y composer_manager
    drush dl -y ctools views api features strongarm features_extra
    drush en -y api features strongarm fe_block api_settings
    drush dis -y comment dblog update shortcut

    # Easy password
    drush upwd admin --password=password

    # Cache clear, enable caching and queue reset
    drush vset block_cache 1
    drush vset --exact cache 1
    drush vset preprocess_css 1
    drush vset preprocess_js 1
    drush vset cache_lifetime 900
    drush vset page_cache_maximum_age 900
    drush vset error_level 0
    drush vset cron_safe_threshold 0
    drush cc all

    # Drupal APIs
    git clone --recursive --depth 1 --branch 8.9.x https://git.drupalcode.org/project/drupal.git $REPO_DIR/drupal-8.9.x
    git clone --recursive --depth 1 --branch 9.0.x https://git.drupalcode.org/project/drupal.git $REPO_DIR/drupal-9.0.x
    git clone --recursive --depth 1 --branch 9.1.x https://git.drupalcode.org/project/drupal.git $REPO_DIR/drupal-9.1.x
    git clone --recursive --depth 1 --branch 9.2.x https://git.drupalcode.org/project/drupal.git $REPO_DIR/drupal-9.2.x

    # Install deps for each API
    composer install -d $REPO_DIR/drupal-8.9.x
    composer install -d $REPO_DIR/drupal-9.0.x
    composer install -d $REPO_DIR/drupal-9.1.x
    composer install -d $REPO_DIR/drupal-9.2.x

    # Disable fallback branching
    sed -i 's/return $fallback_branch;/#return $fallback_branch;/g' $APACHE_DOCUMENT_ROOT/sites/all/modules/api/api.module

    # Enable APIs. First one becomes preferred.
    drush api-ensure-branch "drupal" "Drupal Core" "core" "9.1.x" "Drupal 9.1.x" "$REPO_DIR/drupal-9.1.x" "9.1.x" 1

    # Other APIs.
    drush api-ensure-branch "drupal" "Drupal Core" "core" "8.9.x" "Drupal 8.9.x" "$REPO_DIR/drupal-8.9.x" "8.9.x" 1
    drush api-ensure-branch "drupal" "Drupal Core" "core" "9.0.x" "Drupal 9.0.x" "$REPO_DIR/drupal-9.0.x" "9.0.x" 1
    drush api-ensure-branch "drupal" "Drupal Core" "core" "9.2.x" "Drupal 9.2.x" "$REPO_DIR/drupal-9.2.x" "9.2.x" 1

    # Restore change
    sed -i 's/#return $fallback_branch;/return $fallback_branch;/g' $APACHE_DOCUMENT_ROOT/sites/all/modules/api/api.module
fi

# Cleanup permissions
chown -R www-data:www-data $APACHE_DOCUMENT_ROOT/sites

# Always trigger a cron on start
echo "Running cron, this make take a while... Website will not be accessible until this finishes."
drush cron

# Serve website
echo "API site setup complete. Cron container will continue to process in background."
apache2-foreground