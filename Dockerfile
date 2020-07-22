FROM openjdk:11-jre

RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends locales postgresql-client default-mysql-client \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV NEW_RELIC_APP_NAME="mirth-test"
ENV NEW_RELIC_LICENSE_KEY="d17e29eefdf939555f3b7809ce236c0cbbb36101"
ENV NEW_RELIC_LOG_FILE_NAME="STDOUT"
ENV NEW_RELIC_ENABLED="false"

RUN curl -SL 'https://s3.amazonaws.com/downloads.mirthcorp.com/connect/3.9.0.b2526/mirthconnect-3.9.0.b2526-unix.tar.gz' \
    | tar -xzC /opt \
    && mv "/opt/Mirth Connect" /opt/connect

RUN useradd -u 1000 mirth
RUN mkdir -p /opt/connect/appdata && chown -R mirth:mirth /opt/connect/appdata

VOLUME /opt/connect/appdata
VOLUME /opt/connect/custom-extensions
WORKDIR /opt/connect
RUN rm -rf cli-lib manager-lib \
    && rm mirth-cli-launcher.jar mirth-manager-launcher.jar mccommand mcmanager
RUN (cat mcserver.vmoptions /opt/connect/docs/mcservice-java9+.vmoptions ; echo "") > mcserver_base.vmoptions
EXPOSE 8443

RUN curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && unzip newrelic-java.zip && rm -rf newrelic-java.zip

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

RUN chown -R mirth:mirth /opt/connect
USER mirth
CMD ["./mcserver"]