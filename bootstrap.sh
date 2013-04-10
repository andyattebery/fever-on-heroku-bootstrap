#!/bin/sh
set -e

APP_NAME=$1

# Initialize git repo for Fever
mkdir -p fever
cd fever
git init .

# Download Fever source code and expand it
curl -s -O http://feedafever.com/gateway/public/fever.zip
unzip -q fever.zip -d . && rm fever.zip
echo '<meta http-equiv="refresh" content="3;URL=/fever/boot.php">' > index.php

# First commit
git add -A .
git commit -m "Added Fever bootstrap code, Heroku index.php"

# Set up heroku app with custome build pack for PHP
echo ""
echo ""
heroku login
heroku create ${APP_NAME} -s cedar -b git://github.com/iphoting/heroku-buildpack-php-tyler.git
heroku addons:add xeround:starter
heroku addons:add scheduler:standard
git push heroku master


/bin/echo -n "Waiting for deploying MySQL DB..."
while [ `heroku config | grep -c XEROUND_DATABASE_HOST` = 0 ]
do
  /bin/echo -n '.'
done

# Show Database Info
echo ""
echo ""
echo "Here is MySQL database credential"
echo "========================================"
heroku config | grep XEROUND_DATABASE_URL | tr '@' ':' | tr '/' ':'| awk -F: '{gsub("\.$",":",$7); print("HOST: " $7 $8 "\nNAME: " $9 "\nUSERNAME: " $5 "\nPASSWORD: " $6) }'
echo "========================================"


# Show additional actions
echo ""
echo ""
echo "==== Additional actions ===="
echo ""
echo "[Setup Automatic Refresh]"
echo "To set up automatic refresh, run the following command. It will open Heroku Scheduler website."
echo ""
echo "    heroku addons:open scheduler"
echo ""
echo "Then enter the following command to the command field."
echo ""
echo "    curl -L -s http://YOUR_HEROKU_APP/fever/?refresh"
echo ""
echo ""
echo "[Change Item Expiration]"
echo "Becuase MySQL addon Xeround which your Fever used has a limitation of 10MB storage, you should change item expiration to 2 weeks to save the storage."
echo ""
echo ""
echo "[Pinging to server]"
echo "Becuase Heroku will restart the instance every day, causing Fever lock you out, if you aren't constantly hitting the page, "
echo "you should setup cron in your Mac so that your Mac access the page every minute to prevent this, or using a monitoring service such as pingdom.com."
echo ""

# Open launch page
heroku open