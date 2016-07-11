#!/bin/bash

if [[ ! -d /opt/nvm ]]; then
    echo "$0 ERROR: nvm is not pre-installed on mounted volume /opt."
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1
then
    echo "$0 ERROR: $(pwd) should be a git dir for your project but is not."
    exit 1
fi
.  /opt/profile.d/nvm.sh
nvm use
echo "$0 INFO: ... installing npm modules"
npm -d install || exit 1
echo "$0 INFO: ... installing jspm npm module globally"
npm install jspm -g || exit 1

echo "$0 INFO: ... installing jspm modules"
jspm install || exit 1

echo "$0 INFO: ... running composer update and install"
composer config --global discard-changes true
composer update || exit 1
composer -vvv --no-interaction install || exit 1

echo "$0 INFO: ... installing gulp modules"
./node_modules/.bin/gulp prod || exit 1

exit 0
