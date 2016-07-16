#!/bin/bash

NVM_DIR=/opt/nvm/.nvm 
NPM_VERSION=${NPM_VERSION:-0.12.7}
export NVM_DIR

# ... sanity check
if [[ ! -d $NVM_DIR ]]; then
    echo "$0 ERROR: nvm is not pre-installed on mounted volume /opt."
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1
then
    echo "$0 ERROR: $(pwd) should be a git dir for your project but is not."
    exit 1
fi

# ... prepare stuff
echo "$0 INFO: ... sourcing nvm"
.  /opt/nvm/.nvm/nvm.sh
echo "$0 INFO: ... installing npm"
nvm install $NPM_VERSION
echo "$0 INFO: ... installing npm modules"
npm -d install || exit 1
echo "$0 INFO: ... installing jspm npm module globally"
npm install jspm -g || exit 1

echo "$0 INFO: ... installing jspm modules"
jspm install || exit 1

echo "$0 INFO: ... running composer install"
composer config --global discard-changes true
composer -vvv --no-interaction install || exit 1

echo "$0 INFO: ... installing gulp modules"
./node_modules/.bin/gulp prod || exit 1

exit 0
