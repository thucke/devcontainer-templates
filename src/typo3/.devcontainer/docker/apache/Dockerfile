# stick to bookworm until mysqldump supports trixie (Debian 13)
FROM php:8.4-apache-trixie

# https://github.com/xdebug/xdebug/releases
ARG XDEBUG_VERSION=3.5.0

ARG DEVCONTAINER_SERVICE_ID
ARG DEVCONTAINER_SERVICE_NAME
ARG COMPOSE_PROFILES
ARG APACHE_DOCUMENT_ROOT

ENV DEVCONTAINER_SERVICE_ID=${DEVCONTAINER_SERVICE_ID}
ENV DEVCONTAINER_SERVICE_NAME=${DEVCONTAINER_SERVICE_NAME}
ENV APACHE_RUN_USER=${DEVCONTAINER_SERVICE_NAME}
ENV APACHE_RUN_GROUP=${DEVCONTAINER_SERVICE_NAME}
ENV COMPOSE_PROFILES=${COMPOSE_PROFILES}
ENV APACHE_DOCUMENT_ROOT=${APACHE_DOCUMENT_ROOT}

EXPOSE 80 443
USER root

COPY docker/typo3/php.ini /usr/local/etc/php/php.ini

RUN addgroup --gid ${DEVCONTAINER_SERVICE_ID} ${DEVCONTAINER_SERVICE_NAME} && \
    adduser --gid ${DEVCONTAINER_SERVICE_ID} --no-create-home --home /nonexistent --comment "devcontainer service user" \
        --disabled-password --shell /bin/false --uid ${DEVCONTAINER_SERVICE_ID} $DEVCONTAINER_SERVICE_NAME

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
    update-locale LANG=en_US.UTF-8 &&\
    sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf && \
    sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
    echo "UseCanonicalName On" >>../apache2.conf && \
    ln -sfr /etc/apache2/mods-available/expires.load /etc/apache2/mods-enabled/expires.load && \
    ln -sfr /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load

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
    chmod -c +x "$COMPOSER_BINARY"

##################################################################################
# configuration according to https://docs.typo3.org/m/typo3/reference-coreapi/main/en-us/Administration/Installation/SystemRequirements/Index.html#using-typo3-with-docker-based-environments
##################################################################################
# Enable Apache mod_rewrite
RUN a2enmod rewrite
