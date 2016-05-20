FROM gliderlabs/alpine:3.3
MAINTAINER Jinal Shah <jnshah@gmail.com>
LABEL Name="dev_basic" Description="basic workspace process" Vendor="sortuniq" Version="0.0.5"
# build instructions:
# # ... build and tag as stable
# img_name=$(grep '^LABEL ' ./Dockerfile | sed -e 's/.*Name="\([^"]\+\).*/\1/')
# tag_version=$(grep '^LABEL ' ./Dockerfile | sed -e 's/.*Version="\([^"]\+\).*/\1/')
# docker build --no-cache=true --rm --tag $img_name:$tag_version .
# docker rmi $img_name:stable 2>/dev/null
# docker tag $img_name:$tag_version $img_name:stable

ARG VIM_INDENT=4
ENV VIM_INDENT $VIM_INDENT \
    SCRIPTS_LOCAL="./build-scripts-alpine" \
    SCRIPTS_DOCKER="/var/tmp/scripts"

COPY $SCRIPTS_LOCAL $SCRIPTS_DOCKER
RUN  chmod a+x $SCRIPTS_DOCKER/*     \
  && apk add --no-cache bash         \
  && apk add --no-cache curl         \
  && apk add --no-cache git          \
  && apk add --no-cache tree         \
  && apk add --no-cache --update sed \
  && /usr/bin/env bash $SCRIPTS_DOCKER/install_vim.sh \
  && rm -rf /var/cache/apk/* $SCRIPTS_DOCKER

CMD ["/bin/true"]
