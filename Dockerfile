FROM fluent/fluentd:v0.12-debian-onbuild
MAINTAINER Doug Szumski <doug@stackhpc.com>

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps

# Install a custom fluentd output plugin that forwards logs to the monasca
# log API.
ADD https://github.com/stackhpc/fluentd-monasca/archive/master.tar.gz /fluentd-monasca.tar.gz

RUN mkdir /fluentd-monasca \
    && cd /fluentd-monasca \
    && tar -zxf /fluentd-monasca.tar.gz \
    && rm /fluentd-monasca.tar.gz
RUN cd /fluentd-monasca/fluentd-monasca-master \
    && gem build fluentd-monasca-output.gemspec \
    && gem install fluentd-monasca-output-0.0.1.gem \
    && fluent-gem install fluentd-monasca-output-0.0.1.gem

RUN gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

EXPOSE 24284