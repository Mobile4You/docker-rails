FROM m4ucorp/tools:base-image-0.9.19
MAINTAINER Leonardo Bernardelli <leonardo.bernardelli@m4u.com.br>

ENV _USER app
ENV LANG en_US.UTF-8

ENV RUBY_MAJOR "2.4"
ENV RUBY_VERSION "2.4.1"
ENV RUBYGEMS_VERSION "2.6.8"
ENV BUNDLER_VERSION "1.15.2"

ENV APT_PACKAGES "\
gcc g++ make patch binutils libc6-dev \
  libjemalloc-dev libffi-dev libssl-dev libyaml-dev zlib1g-dev libgmp-dev libxml2-dev \
  libxslt1-dev libreadline-dev libsqlite3-dev \
  libpq-dev unixodbc unixodbc-dev unixodbc-bin ruby-odbc freetds-bin freetds-common freetds-dev postgresql-client \
  git nodejs\
"

ENV APT_REMOVE_PACKAGES "openssh-server"

ENV RM_ITEMS "\
/tmp/* /var/tmp/* /var/lib/apt/lists/* /var/lib/apt /var/lib/dpkg /var/backups/* /usr/share/man /usr/share/doc\
"

RUN locale-gen $LANG && dpkg-reconfigure locales && /usr/sbin/update-locale LANG=$LANG

RUN printf 'APT::Get::Install-Recommends "false";\nDpkg::Options {\n"--force-confdef";\n"--force-confold";\n}' \
> /etc/apt/apt.conf.d/local && apt-get update && apt-get -y dist-upgrade && \
apt-get install -y --no-install-recommends $APT_PACKAGES && \
apt-get remove --purge -y $APT_REMOVE_PACKAGES && apt-get autoremove --purge -y && apt-get clean && \
rm -rf $RM_ITEMS /etc/my_init.d/00_regen_ssh_host_keys.sh /etc/service/sshd /etc/cron.daily/{apt,passwd}

WORKDIR /tmp
RUN curl "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.gz" |\
  tar -xz && \
  cd ruby-${RUBY_VERSION} && \
  ./configure --enable-shared --with-jemalloc --disable-install-doc && \
  make -j4 && make install && \
  rm -rf $RM_ITEMS

ENV HOME /$_USER
RUN adduser --disabled-password --home=$HOME --gecos "" $_USER && mkdir $HOME/webapp && chown $_USER:$_USER -R $HOME

WORKDIR $HOME
ENV GEM_SPEC_CACHE "/tmp/gemspec"
ENV GEM_HOME "$HOME/gem-home"
ENV PATH "$GEM_HOME/bin:$PATH"

RUN printf 'gem: --no-document' > .gemrc && \
  gem --config-file .gemrc update --system ${RUBYGEMS_VERSION} && \
  gem --config-file .gemrc install -v ${BUNDLER_VERSION} bundler && \
  rm -rf "$GEM_HOME"/cache && \
  rm -rf $RM_ITEMS

RUN printf "#!/bin/sh\ndate > /tmp/boot-time.txt" > /etc/my_init.d/00-log-boot-time.sh

# Use baseimage-docker's init system.
ENTRYPOINT ["/sbin/my_init"]

COPY puma.rb /etc/
COPY $_USER-service.sh $_USER.sh $HOME/
# Possible rocker bug: $HOME is empty
RUN chmod -R 700 /etc/my_init.d && echo "$HOME" > /etc/container_environment/HOME && \
  printf '#!/bin/bash\ntar -jxf vendor.tbz -C "$HOME"/vendor' > /etc/my_init.d/01-vendor-cache.sh

ONBUILD COPY Gemfile* ./
#ONBUILD MOUNT vendor:/app/vendor
ONBUILD COPY vendor /app/vendor
ONBUILD RUN bundle install --no-cache --jobs 4 --retry 3 --local && \
  rm -rf "./gem-home"/cache

ONBUILD RUN mkdir -p /etc/service/app && mv /app/app-service.sh /etc/service/app/run && chmod +x /etc/service/app/run
ONBUILD COPY . /app/
ONBUILD RUN chown -R nobody:nogroup /app ; chmod -f +x app.sh; \
if test -f crontab; then \
  chown app:crontab crontab && chmod 600 crontab && \
  mv crontab /var/spool/cron/crontabs/app; \
fi; \
if test -f db-migrate.sh; then \
  chown root:root db-migrate.sh && chmod 700 db-migrate.sh && \
  mv db-migrate.sh /etc/my_init.d/90-db-migrate.sh; \
fi;

ONBUILD EXPOSE 8080
