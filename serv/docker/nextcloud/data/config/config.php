<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => 
  array (
    'host' => 'redis',
    'password' => '',
    'port' => 6379,
  ),
  'upgrade.disable-web' => true,
  'passwordsalt' => 'f2iC5HbmfCqZqR+Dr8gL0Div3zAJ4z',
  'secret' => 'U/7SeXceW0iAl+zbSVxeodxqPg3+6RbR9uJinEnCuZ+YfB+H',
  'trusted_domains' => 
  array (
    0 => 'localhost',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'pgsql',
  'version' => '29.0.16.1',
  'overwrite.cli.url' => 'http://localhost',
  'dbname' => 'nextcloud',
  'dbhost' => 'postgres',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'dbuser' => 'nc',
  'dbpassword' => 'postgres',
);
