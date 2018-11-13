FROM php:7.1-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        libpq-dev \
        libmcrypt-dev \
        libpng-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libxml2-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install mcrypt pgsql pdo pdo_pgsql mbstring exif soap zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV COMPOSER_ALLOW_SUPERUSER true
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo --prefer-dist --no-interaction \
    && rm -rf /root/.composer/cache/*

VOLUME ["/app"]
WORKDIR /app

COPY php.ini /usr/local/etc/php/conf.d/extra_php.ini

RUN echo 'PATH=$PATH:/app/vendor/bin' >> /root/.bashrc \
    && ln -s /app/artisan /usr/local/bin/

CMD ["bash", "--rcfile", "/root/.bashrc"]

