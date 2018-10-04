FROM tomcat:6-jre8
LABEL MAINTAINER="UNICEF"
ARG DEVELOP
ARG VERSION
ARG FLYWAY=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.0.3/flyway-commandline-4.0.3-linux-x64.tar.gz
ARG ODK=https://github.com/opendatakit/aggregate/releases/download/v1.6.1/ODK-Aggregate-v1.6.1-Linux-x64.run
ENV CONFIGURE=1

RUN apt-get update \
    && apt-get install default-jdk -y --no-install-recommends \
    && mkdir /opt/flyway/ /files/ /var/odk/


COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY odk.options /files/
COPY cache /files

WORKDIR /files
RUN ls /files/

RUN set -e; if [ ! -f /files/flyway.tar.gz ]; then curl -L $FLYWAY -o /files/flyway.tar.gz; fi; \
    if [ ! -f /files/odk.run ]; then curl -L $ODK -o /files/odk.run; fi; \
    tar -xvzf /files/flyway.tar.gz -C  /opt/flyway/ --strip-components=1 \
    && chmod +x /files/odk.run \
    && /files/odk.run --optionfile /files/odk.options \
    && cp "/odk/ODK Aggregate/ODKAggregate.war" $CATALINA_HOME/webapps/ROOT.war \
    && rm -fr /files

#RUN apt-get autoremove \
#    default-jdk -y

WORKDIR /

EXPOSE 8080

ENTRYPOINT ["entrypoint.sh"]

CMD ["odk"]
