#!/bin/bash
set -e

DRUPALTABLE='/var/www/html/database/mysql/drupal/users.frm'
echo 'Because we are sharing the database at ./database/mysql, we can check'
echo 'whether the site has already been installed by checking whether'
echo "$DRUPALTABLE exists on the container."
if [ ! -f "$DRUPALTABLE" ]; then
  echo 'Because it does not, we can determine that the site has not yet'
  echo 'been installed, so we will install it.'

  cd /var/www/html && \
    drush si \
    -y --db-url=mysql://drupal:drupal@database:3306/drupal

  cd /var/www/html && \
    drush en manage_deploy -y && \
    chown -R www-data:www-data ./sites/default/files && \
    drush cc all
else
  echo 'Because it exists, we will simply update the existing site.'
  echo 'First let us wait 15 seconds for the MySQL server to fire up.'
  sleep 15
  cd /var/www/html && \
    # Force new dependencies.
    drush dis manage_deploy -y && \
    drush en manage_deploy -y && \
    drush vset maintenance_mode 1 && \
    drush rr && \
    drush cc all && \
    drush updb -y && \
    drush vset maintenance_mode 0
fi
