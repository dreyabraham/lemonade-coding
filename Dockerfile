# Step 1: Use an official PHP image with extensions for Laravel
FROM php:8.1-fpm

# Step 2: Set working directory
WORKDIR /var/www/html

# Step 3: Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring gd xml zip bcmath

# Step 4: Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Step 5: Copy application code
COPY . /var/www/html

# Step 6: Set permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Step 7: Install application dependencies
RUN composer install --no-dev --optimize-autoloader

# Step 8: Expose port (if running Laravel development server)
EXPOSE 8000

# Step 9: Define the command to run the application
CMD ["php-fpm"]
