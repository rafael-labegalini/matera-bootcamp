FROM php:8.1-cli
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash && \
    apt-get update && \
    apt-get install -y git nodejs

COPY ./example-app /var/www/app

WORKDIR /var/www/app

RUN composer install -o --no-dev && \
    cp .env.example .env && \
    rm -f .env.example && \
    php artisan key:generate --ansi && \
    npm install && \
    npm run prod && \
    docker-php-ext-install opcache

ENV APP_ENV=production
ENV APP_DEBUG=false

ENTRYPOINT ["php", "artisan"]
CMD ["serve", "--host=0.0.0.0"]

EXPOSE 8000