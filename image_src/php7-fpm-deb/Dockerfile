FROM debian:jessie
# ... from https://github.com/docker-library/php/blob/master/7.0/fpm/Dockerfile
# - reducing layers
# - with bcmath enabled
# - with work dir changed
#
# --enable-mysqlnd: included here because it's also a plugin, not just an extension.
#                  This makes it harder to compile after php is compiled.
#
# --enable-mbstring: included here because of pecl issue.
#                    see https://github.com/docker-library/php/issues/195
#
MAINTAINER jinal--shah <jnshah@gmail.com>
LABEL Name="php7-fpm-deb" Vendor="sortuniq" Version="0.0.1" \
      Description="provides php-fpm on debian base - entrypoint is php-fpm"
# build instructions:
# img_name=$(grep '^LABEL ' ./Dockerfile | sed -e 's/.*Name="\([^"]\+\).*/\1/')
# tag_version=$(grep '^LABEL ' ./Dockerfile | sed -e 's/.*Version="\([^"]\+\).*/\1/')
# docker build --no-cache=true --rm --tag $img_name:$tag_version .
# docker rmi $img_name:stable 2>/dev/null
# docker tag $img_name:$tag_version $img_name:stable

# persistent / runtime deps
ENV PHPIZE_DEPS="autoconf file g++ gcc libc-dev make pkg-config re2c" \
    BUILD_DEPS="libcurl4-openssl-dev libedit-dev libsqlite3-dev libssl-dev libxml2-dev xz-utils" \
    PHP_INI_DIR="/usr/local/etc/php"                                  \
    PHP_MODS="--enable-bcmath --enable-fpm"                           \
    SET_FPM_USER="--with-fpm-user=www-data --with-fpm-group=www-data" \
    GPG_KEYS=1A4E8B7277C42E53DBA9C7B9BCAA30EA9C0D5763                 \
    PHP_VERSION=7.0.7                                                 \
    PHP_FILENAME=php-7.0.7.tar.xz                                     \
    PHP_SHA256=9cc64a7459242c79c10e79d74feaf5bae3541f604966ceb600c3d2e8f5fe4794

ENV PHP_EXTRA_CONFIGURE_ARGS="${PHP_MODS} ${SET_FPM_USER}"                \
    PHP_URI="http://php.net/get/${PHP_FILENAME}/from/this/mirror"         \
    PHP_ASC_URI="http://php.net/get/${PHP_FILENAME}.asc/from/this/mirror" \

RUN apt-get update                                \
    && apt-get install -y --no-install-recommends \
        $PHPIZE_DEPS                              \
        $BUILD_DEPS                               \
        ca-certificates                           \
        curl                                      \
        libedit2                                  \
        libsqlite3-0                              \
        libxml2                                   \
    && rm -r /var/lib/apt/lists/*                 \
    && mkdir -p $PHP_INI_DIR/conf.d               \ 
    && curl -fSL "$PHP_URI" -o "$PHP_FILENAME"    \
    && echo "$PHP_SHA256 *$PHP_FILENAME" | sha256sum -c - \
    && curl -fSL "$PHP_ASC_URI" -o "$PHP_FILENAME.asc"    \
    && export GNUPGHOME="$(mktemp -d)"                    \
    && for key in $GPG_KEYS; do                           \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    done \
    && gpg --batch --verify "$PHP_FILENAME.asc" "$PHP_FILENAME" \
    && rm -r "$GNUPGHOME" "$PHP_FILENAME.asc" \
    && mkdir -p /usr/src/php \
    && tar -xf "$PHP_FILENAME" -C /usr/src/php --strip-components=1 \
    && rm "$PHP_FILENAME" \
    && cd /usr/src/php \
    && ./configure \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        $PHP_EXTRA_CONFIGURE_ARGS \
        --disable-cgi \
        --enable-mysqlnd \
        --enable-mbstring \
        --with-curl \
        --with-libedit \
        --with-openssl \
        --with-zlib \
    && make -j"$(nproc)" \
    && make install \
    && { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
    && make clean \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $BUILD_DEPS

COPY docker-php-ext-* /usr/local/bin/

WORKDIR /srv/eurostar/htdocs

RUN set -ex \
    && cd /usr/local/etc \
    && if [ -d php-fpm.d ]; then \
        # for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
        sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
        cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
    else \
        # PHP 5.x don't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
        mkdir php-fpm.d; \
        cp php-fpm.conf.default php-fpm.d/www.conf; \
        { \
            echo '[global]'; \
            echo 'include=etc/php-fpm.d/*.conf'; \
        } | tee php-fpm.conf; \
    fi \
    && { \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo; \
        echo '[www]'; \
        echo '; if we send this to /proc/self/fd/1, it never appears'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
    } | tee php-fpm.d/docker.conf \
    && { \
        echo '[global]'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo 'listen = [::]:9000'; \
    } | tee php-fpm.d/zz-docker.conf

EXPOSE 9000
CMD ["php-fpm"]
