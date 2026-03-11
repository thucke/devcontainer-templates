# https://hub.docker.com/_/php
# using moby in docker-in-docker extension is not supported by trixie
FROM php:8.4-fpm-trixie

# https://github.com/xdebug/xdebug/releases
ARG XDEBUG_VERSION=3.5.0

ARG DEVCONTAINER_SERVICE_ID
ARG DEVCONTAINER_SERVICE_NAME
ARG COMPOSE_PROFILES

ENV DEVCONTAINER_SERVICE_ID=${DEVCONTAINER_SERVICE_ID}
ENV DEVCONTAINER_SERVICE_NAME=${DEVCONTAINER_SERVICE_NAME}
ENV COMPOSE_PROFILES=${COMPOSE_PROFILES}

EXPOSE 9000
USER root

COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/typo3/php.ini /etc/php8/fpm/php.ini

RUN addgroup --gid ${DEVCONTAINER_SERVICE_ID} ${DEVCONTAINER_SERVICE_NAME} && \
    adduser --gid ${DEVCONTAINER_SERVICE_ID} --no-create-home --home /nonexistent --comment "devcontainer service user" \
        --disabled-password --shell /bin/false --uid ${DEVCONTAINER_SERVICE_ID} $DEVCONTAINER_SERVICE_NAME && \
    sed -i "s/user\s*=\s*www-data/user\ =\ ${DEVCONTAINER_SERVICE_NAME}/" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/group\s*=\s*www-data/group\ =\ ${DEVCONTAINER_SERVICE_NAME}/" /usr/local/etc/php-fpm.d/www.conf

RUN apt-get update && \
    apt-get install -y \
        libssl-dev libicu-dev \
        libzip-dev zlib1g-dev \
        libgmp-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmagickwand-dev \
        locales locales-all \
        openssh-client \
        vim \
        procps \
        unzip \
        libfcgi-bin \
        imagemagick \
        ghostscript \
        mariadb-client && \
    #apt-get install -y iproute2 iputils-ping && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN docker-php-ext-install calendar bcmath exif ftp gmp intl zip mysqli pdo pdo_mysql && \
    docker-php-ext-enable pdo_mysql && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
    echo 'yes' | pecl install imagick && docker-php-ext-enable imagick && \
    pecl install xdebug-${XDEBUG_VERSION} && docker-php-ext-enable xdebug

#RUN docker-php-ext-enable opcache
#RUN docker-php-ext-install tokenizer
#RUN docker-php-ext-install json
#RUN apt-get install -y \
#        libonig-dev \
#    && docker-php-ext-install iconv mbstring

#RUN apt-get install -y \
#        libcurl4-openssl-dev \
#    && docker-php-ext-install curl

#RUN docker-php-ext-install phar

#RUN apt-get install -y \
#        libmcrypt-dev \
#    && docker-php-ext-install session

#RUN apt-get install -y \
#        libxml2-dev \
#    && docker-php-ext-install simplexml xml
    #&& docker-php-ext-install xmlrpc   https://php.watch/versions/8.0/xmlrpc#alternatives

ENV COMPOSER_BINARY=/usr/local/bin/composer \
    COMPOSER_HOME=/usr/local/composer
ENV PATH=$PATH:$COMPOSER_HOME

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar "$COMPOSER_BINARY" && \
    chmod +x "$COMPOSER_BINARY"

#CMD ["php-fpm", "-D", "-c", "/etc/php8/fpm"]
