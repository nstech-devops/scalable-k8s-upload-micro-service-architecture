FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www
COPY . /var/www

# Production optimizations
RUN composer install --optimize-autoloader --no-dev

# Setup Permissions for Shared Storage Mount
RUN mkdir -p /var/www/storage/app/temp \
    && chown -R www-data:www-data /var/www

# Security: Run as non-root
USER www-data

EXPOSE 9000
CMD ["php-fpm"]
