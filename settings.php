<?php

$databases = [];

$settings['hash_salt'] = 'foobar';

$settings['update_free_access'] = false;

$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';

$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];

$settings['trusted_host_patterns'] = [
  '.+',
];

$settings['entity_update_batch_size'] = 50;

$settings['entity_update_backup'] = true;

$settings['migrate_node_migrate_type_classic'] = false;

$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'user',
  'password' => 'password',
  'prefix' => '',
  'host' => 'mysql',
  'port' => '',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'driver' => 'mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
);

$settings['config_sync_directory'] = '/opt/drupal/config';