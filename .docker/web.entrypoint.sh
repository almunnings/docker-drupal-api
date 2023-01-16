#!/bin/bash

# Enable APIs. First one becomes preferred. Seperate multiple with space.
BRANCH=10.1.x

# Give the database some time to start up.
echo "Waiting for database..."
sleep 10

# Install standard profile.
drush si --existing-config --account-name=admin --account-pass=password -y

# Download a copy of the codebase
git clone --recursive --depth 1 --branch $BRANCH https://git.drupalcode.org/project/drupal.git $REPO_DIR/drupal-$BRANCH

# Install Drupal composer deps
composer install -d $REPO_DIR/drupal-$BRANCH

# Enable branch in API module
drush api:upsert-branch "drupal" "Drupal Core" "core" "$BRANCH" "Drupal $BRANCH" "$REPO_DIR/drupal-$BRANCH" "$BRANCH" 300

# Exclude vendor unit tests and drupalisms on vendors.
drush php-eval "
    \$b = \Drupal\api\Entity\Branch::load(1);
    \$b->exclude_files_regexp = '|/vendor/.+[tT]est|'.PHP_EOL.'|/[tT]ests/.*|';
    \$b->exclude_drupalism_regexp = '|/vendor/|'.PHP_EOL.'|/[tT]ests/|';
    \$b->save();
"

# Cleanup permissions
echo "Checking permissins, this might take a minute..."
chown -R www-data:www-data $REPO_DIR
chown -R www-data:www-data /opt/drupal/web/sites/default/files

# Run cron once.
echo "Running initial cron, this might take a minute..."
drush cron || true
drush cr || true

# Serve website
echo "API site setup complete. Cron container will continue to process in background."
apache2-foreground
