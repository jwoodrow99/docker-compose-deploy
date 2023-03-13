FROM php:8.2.3-fpm

# Set working directory
WORKDIR /var/www/php

# Install dependencies
RUN apt-get update && apt-get install -y \
  git \
  curl \
  wget \
  libpq-dev \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  libzip-dev \
  libjpeg62-turbo-dev \
  libfreetype6-dev \
  zip \
  unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pdo_pgsql pgsql
RUN pecl install redis
RUN docker-php-ext-enable redis

# RUN wget https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar
# RUN php pickle.phar install redis


# Install composer
COPY --from=composer:2.5 /usr/bin/composer /usr/bin/composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]