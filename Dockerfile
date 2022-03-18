FROM php:8.1-cli as buildenv
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get update && \
    apt-get install -y unzip git

COPY ./example-app /var/www/app

WORKDIR /var/www/app

RUN composer install -o --no-dev && \
    cp .env.example .env && \
    rm -f .env.example && \
    php artisan key:generate --ansi

FROM node:14 as buildassets
COPY --from=buildenv /var/www/app /tmp/app
WORKDIR /tmp/app
RUN npm install && npm run prod

FROM php:8.1-cli-alpine

COPY --from=buildassets /tmp/app /var/www/app

RUN docker-php-ext-install opcache
WORKDIR /var/www/app

ENV APP_ENV=production
ENV APP_DEBUG=false

ENTRYPOINT ["php", "artisan"]
CMD ["serve", "--host=0.0.0.0"]

EXPOSE 8000