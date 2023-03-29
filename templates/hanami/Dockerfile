FROM ryansch/fixuid as fixuid

FROM ryansch/ruby:3.2.1
LABEL maintainer="Ryan Schlesinger <ryan@ryanschlesinger.com>"

COPY --from=fixuid /usr/local/bin/fixuid /usr/local/bin/fixuid
COPY --from=fixuid /etc/fixuid/config.yml /etc/fixuid/config.yml
RUN chmod 4755 /usr/local/bin/fixuid

RUN groupadd -g 1000 deploy && \
      useradd -u 1000 -g deploy -ms /bin/bash deploy && \
      mv /usr/local/bin/rake /usr/local/bin/rake.back

COPY --chown=deploy:deploy docker/irbrc /home/deploy/.irbrc

COPY docker/tools-entrypoint.sh /tools-entrypoint.sh
COPY docker/entrypoint.sh /docker-entrypoint.sh

EXPOSE 2300
ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["hanami", "server", "--host", "0.0.0.0"]
