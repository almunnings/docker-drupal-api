#!/bin/bash

cd $APACHE_DOCUMENT_ROOT

# Enable APIs. First one becomes preferred.
BRANCHES=(9.1.x 8.9.x 9.0.x 9.2.x)

# Check if already installed.
if [ ! -f "$APACHE_DOCUMENT_ROOT/sites/default/settings.php" ]; then

    echo "Copying structure..."

    # Prep dir structure, as we've made it a volume.
    cp -Rp /tmp/sites $APACHE_DOCUMENT_ROOT
    chown -R www-data:www-data $APACHE_DOCUMENT_ROOT/sites

    # Give the database some time to start up.
    echo "Waiting for database..."
    sleep 20

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

    # Disable fallback branching
    sed -i 's/return $fallback_branch;/#return $fallback_branch;/g' $APACHE_DOCUMENT_ROOT/sites/all/modules/api/api.module

    for BRANCH in ${BRANCHES[@]}; do
        # Download a copy of the codebase
        git clone --recursive --depth 1 --branch $BRANCH https://git.drupalcode.org/project/drupal.git $REPO_DIR/drupal-$BRANCH
        
        # Install Drupal composer deps
        composer install -d $REPO_DIR/drupal-$BRANCH
        
        # Enable branch in API module
        drush api-ensure-branch "drupal" "Drupal Core" "core" "$BRANCH" "Drupal $BRANCH" "$REPO_DIR/drupal-$BRANCH" "$BRANCH" 300
        
        # Exclude vendor unit tests and drupalisms on vendors.
        drush php-eval "
            module_load_include('inc', 'api', 'api.db'); 
            \$b = api_branch_load('$BRANCH');
            \$b->data = unserialize(\$b->data);
            \$b->data['exclude_files_regexp'] = '/\\/vendor\\/.+[tT]est/';
            \$b->data['exclude_drupalism_regexp'] = '/\\/vendor\\//';
            api_save_branch(\$b);
        "
    done

    # Restore fallback branching
    sed -i 's/#return $fallback_branch;/return $fallback_branch;/g' $APACHE_DOCUMENT_ROOT/sites/all/modules/api/api.module

    # Always trigger a cron on start
    echo "Running cron, this make take a while... Website will not be accessible until this finishes."
    drush cron
fi

# Cleanup permissions
chown -R www-data:www-data $APACHE_DOCUMENT_ROOT/sites

# Serve website
echo "API site setup complete. Cron container will continue to process in background."
apache2-foreground