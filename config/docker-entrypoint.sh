#!/bin/bash

if [ "production" == "$APP_ENV" ]; then
    # Disable xdebug in production
    rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# Start supervisor
/usr/bin/supervisord
