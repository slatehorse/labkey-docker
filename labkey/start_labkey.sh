#!/bin/bash
# 
# Start PostgreSQL and Tomcat Services 
# 

# Start X Virtual Frame Buffer 
/labkey/bin/xvfb.sh start

# Start PostgreSQL
/etc/init.d/postgresql start 

# Start Tomcat 
/labkey/apps/tomcat/bin/catalina.sh run \
  --catalina-base /labkey/apps/tomcat \
  --catalina-home /labkey/apps/tomcat \
  --tomcat-user tomcat