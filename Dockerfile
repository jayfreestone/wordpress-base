ARG PHP_ALPINE_TAG=7.2-fpm-alpine3.8

FROM php:${PHP_ALPINE_TAG}

ENV APP_DIR /var/www/html

# Install packages from testing repo's
RUN apk --no-cache add nginx redis supervisor curl bash openrc vim \
    # XDebug dependencies
    autoconf gcc make g++ zlib-dev

# Install the PHP extensions we need
RUN apk add --no-cache --virtual .build-deps \
        libjpeg-turbo-dev \
        libpng-dev && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
    docker-php-ext-install gd mysqli opcache zip

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install XDebug
RUN pecl install xdebug && \
    docker-php-ext-enable xdebug

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Sane bindings/settings for SSh'ing
COPY config/.inputrc /root
COPY config/.bashrc /root

# Configure supervisord
COPY config/supervisord.conf /etc/supervisord.conf

# Configure nginx
COPY config/nginx/ /etc/nginx/

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Customize PHP setup
COPY config/php/conf.d/ /usr/local/etc/php/conf.d/
COPY config/php/php-fpm.d/ /etc/php-fpm.d/

COPY config/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
