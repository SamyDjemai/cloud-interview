ARG PHP_VERSION=7.2

# Stage 1: Create base image with php-fpm and extensions
FROM php:${PHP_VERSION}-fpm as base

WORKDIR /app

## Add healthcheck script for fpm
RUN apt-get update -y && apt-get install -y libfcgi-bin && \
    curl -o /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck && \
    chmod +x /usr/local/bin/php-fpm-healthcheck

## Install PHP extensions
RUN curl -sSLf -o /usr/local/bin/install-php-extensions \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions intl opcache

## Configure opcache extension
ENV PHP_OPCACHE_MEMORY_CONSUMPTION="128"
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES="4000"
RUN { \
    echo 'opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}'; \
    echo 'opcache.max_accelerated_files=${PHP_OPCACHE_MAX_ACCELERATED_FILES}'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

## Set PHP settings for Container
ENV PHP_MEMORY_LIMIT="256M"
ENV PHP_TZ="Europe/Paris"
RUN { \
    echo 'date.timezone=${PHP_TZ}'; \
    echo 'memory_limit=${PHP_MEMORY_LIMIT}'; \
    } > /usr/local/etc/php/conf.d/container.ini

## Enable PHP-FPM healthcheck
RUN echo 'pm.status_path=/status' > /usr/local/etc/php-fpm.d/healthcheck.conf

# Stage 2: create a base image for composer
FROM base as composer

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN install-php-extensions @composer-2

# Stage 2b: Install vendor libs
FROM composer as vendor

COPY --link composer.* ./

RUN composer install --prefer-dist --no-dev --no-scripts --no-progress

## Stage 3: Final dev image (no vendor inside)
FROM composer as dev

RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

## Stage 3b: Production image (with vendor and sources)
FROM base as production

RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Copy app in the production image
COPY --link --from=vendor /app/vendor ./vendor
COPY --link . .
