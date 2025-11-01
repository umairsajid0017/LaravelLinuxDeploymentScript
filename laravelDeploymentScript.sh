#!/bin/bash

PROJECT_DIR="ABC_Project"
PHP_VERSION=""
#GROUP="www-data"
GROUP="daemon"


BASE_PATH="$(pwd)"
WEB_ROOT=$BASE_PATH"/$PROJECT_DIR"
MY_USER=$(whoami)
# sudo docker exec -i mysql8 mysql -uroot -p1234 db < "db.sql"
# sudo docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql8
#sudo usermod -aG $GROUP $(whoami)
#su - $(whoami)

sudo apt update
sudo apt install -y php${PHP_VERSION} libapache2-mod-php${PHP_VERSION}
sudo apt install php${PHP_VERSION}-curl
sudo apt install php${PHP_VERSION}-xml
sudo apt install php${PHP_VERSION}-mysqli
sudo apt install php${PHP_VERSION}-intl
sudo apt install php${PHP_VERSION}-mbstring
sudo apt install php${PHP_VERSION}-iconv



sudo a2enmod php${PHP_VERSION}
sudo a2enmod rewrite
#sudo systemctl restart apache2
sudo /opt/bitnami/ctlscript.sh restart
#sudo systemctl restart httpd
#sudo systemctl restart ngnix


sudo chown -R $MY_USER:$GROUP $BASE_PATH
sudo chmod -R 775 $BASE_PATH

# Create directories step by step
cd $WEB_ROOT
[ ! -e .env ] && cp .env.example .env

cd bootstrap
mkdir -p cache
cd $WEB_ROOT
cd storage/framework
mkdir -p sessions
mkdir -p cache
mkdir -p views
mkdir -p logs
cd cache
mkdir -p data
ln -s public/assets assets

cd $WEB_ROOT
rm -rf vendor
rm composer.lock
sudo apt install composer
composer install
composer dump-autoload

sudo chown -R $MY_USER:$GROUP $WEB_ROOT

sudo chown -R $MY_USER:$GROUP $WEB_ROOT/storage $WEB_ROOT/bootstrap/cache $WEB_ROOT/.env

sudo chmod -R 775 $WEB_ROOT/storage $WEB_ROOT/bootstrap/cache

sudo chmod 664 $WEB_ROOT/.env

sudo -u $MY_USER php${PHP_VERSION} artisan key:generate
sudo -u $MY_USER php${PHP_VERSION}  artisan config:cache
sudo -u $MY_USER php${PHP_VERSION}  artisan cache:clear
sudo -u $MY_USER php${PHP_VERSION}  artisan config:clear
sudo -u $MY_USER php${PHP_VERSION}  artisan route:clear
sudo -u $MY_USER php${PHP_VERSION}  artisan view:clear
sudo -u $MY_USER php${PHP_VERSION}  artisan optimize:clear
sudo -u $MY_USER php${PHP_VERSION}  artisan config:cache

# Install latest Node.js (required for Yarn)
echo "Installing/updating to latest Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
NODE_VERSION=$(node -v)
echo "✓ Node.js installed: $NODE_VERSION"

# Install Yarn if not already installed
if ! command -v yarn >/dev/null 2>&1; then
    echo "Installing Yarn..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update
    sudo apt install -y yarn
fi

# Install Node dependencies with Yarn
cd $WEB_ROOT
if [[ -f "package.json" ]]; then
    echo "Installing Node dependencies with Yarn..."
    yarn install
    echo "✓ Yarn dependencies installed"
else
    echo "⚠ No package.json found, skipping Yarn install"
fi

git config --global core.autocrlf input 
git config core.fileMode false

