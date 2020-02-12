#!/usr/bin/env bash

set -e
set -o pipefail      # don't ignore exit codes when piping output
set -o nounset       # fail on unset variables
unset GIT_DIR        # Avoid GIT_DIR leak from previous build steps
shopt -s nocasematch # So that users can set true, True, or TRUE

#$VCAP_SERVICES environment variable injected during cloud.gov build, 
#for testing script locally uncomment the next line.
#VCAP_SERVICES=$(cat VCAP.json.sample)

# TODO set this dynamically with 
# $ALL_SERVICES+=$(echo $VCAP_SERVICES | jq '.system_env_json."VCAP_SERVICES" | keys[]')
# for SERVICE in $ALL_SERVICES; do

SERVICE="aws-rds"

MYSQL_HOSTNAME=$( echo $VCAP_SERVICES | jq -r '.system_env_json.VCAP_SERVICES["aws-rds"][].credentials.host')
MYSQL_NAME=$( echo $VCAP_SERVICES | jq -r '.system_env_json.VCAP_SERVICES["aws-rds"][].credentials.db_name')
MYSQL_PASSWORD=$( echo $VCAP_SERVICES | jq -r '.system_env_json.VCAP_SERVICES["aws-rds"][].credentials.password')
MYSQL_PORT=$( echo $VCAP_SERVICES | jq -r '.system_env_json.VCAP_SERVICES["aws-rds"][].credentials.port')
MYSQL_USERNAME=$( echo $VCAP_SERVICES | jq -r '.system_env_json.VCAP_SERVICES["aws-rds"][].credentials.username')
MYSQL_URI=$( echo $VCAP_SERVICES | jq -r '.system_env_json.VCAP_SERVICES["aws-rds"][].credentials.uri')

cat > credentials.yml << EOF
---
hostname: ${MYSQL_HOSTNAME}
name: ${MYSQL_NAME}
password: ${MYSQL_PASSWORD}
port: ${MYSQL_PORT}
username: ${MYSQL_USERNAME}
uri: ${MYSQL_URI}

EOF

SONARQUBE_HOME=$(pwd)

cat >> $SONARQUBE_HOME/conf/sonar.properties << EOF

sonar.web.javaAdditionalOpts=-Xmx${env:SONAR_JAVAOPTS_MEMORY}
sonar.ce.javaAdditionalOpts=-Xmx${env:SONAR_JAVAOPTS_MEMORY}

EOF