#!/bin/bash

set -e

if [[ "true" = $NEWRELIC_ENABLED ]]; then

    cp -f /usr/local/etc/php/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini

    echo "newrelic.appname=$NEWRELIC_APP_NAME" >> /usr/local/etc/php/conf.d/newrelic.ini
    echo "newrelic.license=$NEWRELIC_LICENSE" >> /usr/local/etc/php/conf.d/newrelic.ini

    echo "[ OK ] New Relic is enabled"
else
    rm -f /usr/local/etc/php/conf.d/newrelic.ini

    echo "[ OK ] New Relic is disabled"
fi

eval $@
