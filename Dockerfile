FROM ubuntu:17.10

# image metadata
LABEL image.name="k8s-fluentd" \
      image.maintainer="Erik Maciejewski <mr.emacski@gmail.com>"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ruby \
    ruby-dev \
    libjemalloc1 \
  # install utils
  && curl -L https://github.com/emacski/env-config-writer/releases/download/v0.1.0/env-config-writer -o /usr/local/bin/env-config-writer \
  && chmod +x /usr/local/bin/env-config-writer \
  # install fluentd
  && gem install --no-document oj -v 3.1.3 \
  && gem install --no-document fluentd -v 0.14.17 \
  && fluent-gem install --no-document fluent-plugin-kubernetes_metadata_filter -v 0.27.0 \
  && fluent-gem install --no-document fluent-plugin-elasticsearch -v 1.9.5 \
  && fluent-gem install --no-document fluent-plugin-systemd -v 0.2.0 \
  && mkdir -p /etc/fluent && mkdir -p /var/log/fluentd \
  # clean up
  && apt-get remove -y --auto-remove \
    build-essential \
    ruby-dev \
    curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/lib/gems/2.3.0/cache/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1

COPY . /

# build metadata
ARG GIT_URL=none
ARG GIT_COMMIT=none
LABEL build.git.url=$GIT_URL \
      build.git.commit=$GIT_COMMIT

ENTRYPOINT ["/fluentd-config-wrapper"]
CMD ["--log", "/var/log/fluentd.log"]
