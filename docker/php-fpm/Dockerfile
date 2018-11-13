FROM php:7.1-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        libpq-dev \
        libmcrypt-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libxml2-dev \
    && DEBIAN_FRONTEND=noninteractive \
    && curl -sL https://download.newrelic.com/548C16BF.gpg | apt-key add - \
    && echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends newrelic-php5 \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install mcrypt pgsql pdo pdo_pgsql mbstring exif soap zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && newrelic-install install \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /app/artisan /usr/local/bin/

COPY ./php.ini      /usr/local/etc/php/conf.d/
COPY ./newrelic.ini /usr/local/etc/php/

COPY ./www.conf     /usr/local/etc/php-fpm.d/

COPY entrypoint.sh  /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /app

CMD ["php-fpm", "--allow-to-run-as-root"]
