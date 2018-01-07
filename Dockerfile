FROM alpine:latest
RUN apk --update add curl ca-certificates tar && \
    curl -Ls https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.21-r2/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && \
    apk add --allow-untrusted /tmp/glibc-2.21-r2.apk && \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libc.musl-x86_64.so.1 && \
    ln -s /lib/libz.so.1 /usr/lib/libz.so.1 && \
    rm -rf /var/cache/apk/* && \
    rm /tmp/glibc*
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 65
ENV JAVA_VERSION_BUILD 17
ENV JAVA_HOME /opt/jdk
ENV JBOSS_HOME /opt/jboss/wildfly
RUN mkdir /opt 
RUN apk upgrade
RUN apk update
RUN apk add openjdk8
RUN ln -s /usr/lib/jvm/java-1.8-openjdk  /opt/jdk
ENV JAVA_HOME /opt/jdk
RUN  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf
ENV WILDFLY_VERSION 11.0.0.Final
RUN curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz && \
  tar xf wildfly-11.0.0.Final.tar.gz -C /tmp
RUN mkdir -p $JBOSS_HOME 
RUN cp -rf /tmp/wildfly-11.0.0.Final/* $JBOSS_HOME/ 
RUN ls $JBOSS_HOME/
RUN $JBOSS_HOME/bin/add-user.sh admin -p admin -s
ENV POSTGRESQL_VERSION 9.4-1201-jdbc41
ARG DB_HOST=postgresql
ARG DB_NAME=postgresql
ARG DB_USER=postgresql
ARG DB_PASS=postgresql
RUN /bin/sh -c '$JBOSS_HOME/bin/standalone.sh &' && \
  sleep 10 && \
  cd /tmp && \
  curl --location --output postgresql-${POSTGRESQL_VERSION}.jar --url http://search.maven.org/remotecontent?filepath=org/postgresql/postgresql/${POSTGRESQL_VERSION}/postgresql-${POSTGRESQL_VERSION}.jar && \
  $JBOSS_HOME/bin/jboss-cli.sh --connect --command="deploy /tmp/postgresql-${POSTGRESQL_VERSION}.jar" && \
  $JBOSS_HOME/bin/jboss-cli.sh --connect --command="xa-data-source add --name=campstur --jndi-name=java:/jdbc/datasources/campsturDS --user-name=${DB_USER} --password=${DB_PASS} --driver-name=postgresql-9.4-1201-jdbc41.jar --xa-datasource-class=org.postgresql.xa.PGXADataSource --xa-datasource-properties=ServerName=${DB_HOST},PortNumber=5432,DatabaseName=${DB_NAME} --valid-connection-checker-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter" && \
  $JBOSS_HOME/bin/jboss-cli.sh --connect --command=:shutdown && \
  rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/ $JBOSS_HOME/standalone/log/* && \
  rm /tmp/postgresql-9.4*.jar && \
  rm -rf /tmp/postgresql-*.jar
EXPOSE 80 9990

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "-Djboss.http.port=80"]
