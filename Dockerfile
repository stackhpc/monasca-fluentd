ARG TAG=v1.0-debian
FROM fluent/fluentd:$TAG
MAINTAINER Doug Szumski <doug@stackhpc.com>

ARG FLUENTD_MONASCA_VERSION=0.1.2
ARG BUILD_DEPS="make gcc g++ libc-dev ruby-dev"

# Install a custom fluentd output plugin that forwards logs to the monasca log API.
ADD https://github.com/monasca/fluentd-monasca/archive/${FLUENTD_MONASCA_VERSION}.tar.gz fluentd-monasca.tar.gz
RUN apt-get update \
    && apt-get install -y --no-install-recommends ${BUILD_DEPS} \
    && tar -zxf fluentd-monasca.tar.gz \
    && rm fluentd-monasca.tar.gz \
    && cd fluentd-monasca-${FLUENTD_MONASCA_VERSION} \
    && gem build fluentd-monasca-output.gemspec \
    && gem install fluentd-monasca-output-${FLUENTD_MONASCA_VERSION}.gem \
    && fluent-gem install fluentd-monasca-output-${FLUENTD_MONASCA_VERSION}.gem \
    && gem sources --clear-all \
    && SUDO_FORCE_REMOVE=yes \
       apt-get purge -y --auto-remove \
                     -o APT::AutoRemove::RecommendsImportant=false \
                     ${BUILD_DEPS} \
    && rm -rf /var/lib/apt/lists/*

COPY ./fluentd/etc/ /fluentd/etc/

EXPOSE 24284
