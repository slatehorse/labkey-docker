# DOCKER-VERSION 1.0.0
#
# Dockerfile for Standalone LabKey Server. 
# Based heavily on https://github.com/LabKey/samples/tree/master/docker/labkey-standalone.
# Database and LabKey files are a stored inside the container. This is meant for demo only. 
# Developer version of this will use host or container based volumes for Database and 
# LabKey Server file roots.

# Use Ubuntu 14.04 as our base 
from ubuntu:14.04.3
maintainer ryan@ryanbrooks.co.uk

#
# Install the required packages 
#
# We will use Package Manager to install all the PostgreSQL and other required tools
# 
# Apt configuration: Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
run apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
# of PostgreSQL, ``9.4``.
run echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes
run apt-get update

# Install latest patches 
# run DEBIAN_FRONTEND=noninteractive; apt-get -y -q upgrade 

# Install and configure PostgreSQL server 
run (DEBIAN_FRONTEND=noninteractive apt-get -y -q install postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 graphviz; \
     apt-get clean -y )


# Install other required software and OS utilities
# Use this command if you are installing R
#run DEBIAN_FRONTEND=noninteractive; apt-get -y -q install zip unzip graphviz r-base r-recommended r-base-dev curl libcurl4-openssl-dev libgd2-xpm-dev libxt-dev wget netcat xvfb inetutils-ping inetutils-traceroute xvfb

#
# Create directories required for running LabKey Server
# 
run mkdir -p /labkey/labkey /labkey/src/labkey /labkey/bin /labkey/apps

#
# Install Oracle Java 
# 
ADD ./lib/server-jre-8u51-linux-x64.gz /labkey/apps/
ENV JAVA_HOME=/labkey/apps/jdk1.8.0_51
ENV JAVA_OPTS="-Djava.awt.headless=true -Duser.timezone=Europe/London -Xms256M -Xmx2048M -XX:MaxPermSize=196M -Djava.net.preferIPv4Stack=true"

# 
# Install Tomcat 
# 
# Installing this software from source instead of using the APT package 
# as we want to use the latest version and old-ish version in the APT 
# repository

# Create the Tomcat 7 user account 
run useradd -m -u 3000 tomcat

# Install Tomcat binaries
add ./lib/apache-tomcat-8.0.30.tar.gz /labkey/apps
run (ln -s /labkey/apps/apache-tomcat-8.0.30 /labkey/apps/tomcat; \
     mkdir -p /labkey/apps/tomcat/conf/Catalina/localhost; \
    chown -R tomcat.tomcat /labkey/apps/apache-tomcat-8.0.30 )

# Install configuration files
add ./tomcat/server.xml /labkey/apps/tomcat/conf/server.xml 


# 
# Configure the PostgreSQL Server 
# 
add ./postgresql/postgresql.conf /etc/postgresql/9.4/main/postgresql.conf

# Recreate the database server to ensure the default encoding is UTF8
run (rm -rf /var/lib/postgresql/9.4/main; \
     mkdir /var/lib/postgresql/9.4/main; \
     chown postgres.postgres /var/lib/postgresql/9.4/main)

USER postgres
run /usr/lib/postgresql/9.4/bin/initdb --locale=C.UTF-8 -D /var/lib/postgresql/9.4/main

# Create labkey user in postgresql database 
USER postgres
run /etc/init.d/postgresql start &&\
    psql --command "CREATE USER labkey WITH SUPERUSER PASSWORD 'LabKeyOnDockerIsgreaT%04';"

USER root


#
# Install the LabKey Server 
# 

# Copy files to the container 
copy ./lib/LabKey15.3-42135.48-community-bin.tar.gz /labkey/src/labkey-bin.tar.gz
add ./labkey/labkey.xml /labkey/apps/tomcat/conf/Catalina/localhost/ROOT.xml
add ./labkey/start_labkey.sh /labkey/bin/start_labkey.sh
add ./labkey/init_xvfb /labkey/bin/xvfb.sh
run chmod +x /labkey/bin/*

# Install the LabKey Server 
run (tar xzf /labkey/src/labkey-bin.tar.gz; \
     cp -R LabKey15.3-42135.48-community-bin/bin /labkey/labkey; \
     cp -R LabKey15.3-42135.48-community-bin/modules /labkey/labkey; \
     cp -R LabKey15.3-42135.48-community-bin/labkeywebapp /labkey/labkey; \
     cp -R LabKey15.3-42135.48-community-bin/pipeline-lib /labkey/labkey; \
     cp -f LabKey15.3-42135.48-community-bin/tomcat-lib/*.jar /labkey/apps/tomcat/lib/; \
     chown -R tomcat.tomcat /labkey/labkey;)

RUN rm -rf LabKey15.3-42135.48-community-bin


# Expose LabKey Server web application 
expose 8080
VOLUME /labkey/labkey/externalModules

# 
# Start Tomcat and PostgreSQL Daemons when container is started.
# 
WORKDIR /labkey/
CMD /labkey/bin/start_labkey.sh
