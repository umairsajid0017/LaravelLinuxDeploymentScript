#!/bin/bash

PROJECT_DIR="ABC_Project"
BASE_PATH="/var/www/html"
WEB_ROOT=$BASE_PATH"/$PROJECT_DIR"
PHP_VERSION="8.1"
MY_USER="alpha_alex"

sudo apt update
sudo apt install -y php${PHP_VERSION} libapache2-mod-php${PHP_VERSION}

sudo a2enmod php${PHP_VERSION}
sudo a2enmod rewrite
sudo systemctl restart apache2

sudo chown -R $MY_USER:www-data $WEB_ROOT
sudo chmod -R 775 $WEB_ROOT

# Create directories step by step
cd $WEB_ROOT
cp .env.example .env
cd bootstrap
mkdir -p cache
cd $WEB_ROOT
cd storage/framework
mkdir -p sessions
mkdir -p cache
mkdir -p views
cd cache
mkdir -p data


cd $WEB_ROOT
composer install

sudo chown -R www-data:www-data $WEB_ROOT

sudo chown -R www-data:www-data $WEB_ROOT/storage $WEB_ROOT/bootstrap/cache $WEB_ROOT/.env

sudo chmod -R 775 $WEB_ROOT/storage $WEB_ROOT/bootstrap/cache

sudo chmod 664 $WEB_ROOT/.env

sudo -u www-data php artisan key:generate
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan cache:clear
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan route:clear
sudo -u www-data php artisan view:clear
sudo -u www-data php artisan optimize:clear
sudo -u www-data php artisan config:cache
