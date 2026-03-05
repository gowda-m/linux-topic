#!/bin/bash
# ===========================================================
# Zabbix Server (Dockerized) Full Installation Script
# Tested on: RHEL / CentOS / SUSE / Ubuntu / Debian
# Description:
# Automates deployment of Zabbix Server, MySQL, Web UI,
# Java Gateway, and Agent using Docker containers.
# ===========================================================

set -e

MYSQL_DATABASE='zabbix'
MYSQL_USER='user'
MYSQL_PASSWORD='PASS'
MYSQL_ROOT_PASSWORD='pwd'

DB_SERVER_HOST='mysql-server'
ZBX_JAVAGATEWAY='zabbix-java-gateway'
ZBX_SERVER_HOST='zabbix-server-mysql'
ZBX_AGENT_HOSTNAME='docker-agent'

AGENT_CONFIG_DIR='/etc/zabbix/zabbix_agent2.d'

# Remove environment
if [[ $1 == "remove" ]]; then
    echo "Cleaning existing Zabbix containers..."
    docker rm -f mysql-server zabbix-java-gateway zabbix-server-mysql zabbix-web-nginx-mysql zabbix-agent2 2>/dev/null
    docker network rm zabbix-net 2>/dev/null
    echo "Cleanup completed."
    exit 0
fi

echo "Creating Docker network..."
docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net 2>/dev/null || true

echo "Starting MySQL container..."
docker run -d --name $DB_SERVER_HOST \
-e MYSQL_DATABASE="$MYSQL_DATABASE" \
-e MYSQL_USER="$MYSQL_USER" \
-e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
-e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
--network=zabbix-net \
--restart unless-stopped \
mysql:8.0 \
--character-set-server=utf8 \
--collation-server=utf8_bin

echo "Waiting for MySQL..."
until docker exec $DB_SERVER_HOST mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent &>/dev/null; do
    sleep 3
done

echo "Starting Java Gateway..."
docker run -d --name $ZBX_JAVAGATEWAY \
--network=zabbix-net \
--restart unless-stopped \
zabbix/zabbix-java-gateway:alpine-6.4-latest

echo "Starting Zabbix Server..."
docker run -d --name zabbix-server-mysql \
-e DB_SERVER_HOST="$DB_SERVER_HOST" \
-e MYSQL_DATABASE="$MYSQL_DATABASE" \
-e MYSQL_USER="$MYSQL_USER" \
-e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
-e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
-e ZBX_JAVAGATEWAY="$ZBX_JAVAGATEWAY" \
--network=zabbix-net \
-p 10051:10051 \
--restart unless-stopped \
zabbix/zabbix-server-mysql:alpine-6.4-latest

echo "Starting Web UI..."
docker run -d --name zabbix-web-nginx-mysql \
-e ZBX_SERVER_HOST="$ZBX_SERVER_HOST" \
-e DB_SERVER_HOST="$DB_SERVER_HOST" \
-e MYSQL_DATABASE="$MYSQL_DATABASE" \
-e MYSQL_USER="$MYSQL_USER" \
-e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
-e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
--network=zabbix-net \
-p 8080:8080 \
--restart unless-stopped \
zabbix/zabbix-web-nginx-mysql:alpine-6.4-latest

echo "Starting Zabbix Agent..."
mkdir -p $AGENT_CONFIG_DIR

docker run -d --name zabbix-agent2 \
--hostname $ZBX_AGENT_HOSTNAME \
-p 10050:10050 \
-e ZBX_SERVER_HOST="$ZBX_SERVER_HOST" \
-e ZBX_SERVER_ACTIVE="$ZBX_SERVER_HOST" \
-v $AGENT_CONFIG_DIR:/etc/zabbix/zabbix_agent2.d:ro \
--network=zabbix-net \
--restart unless-stopped \
zabbix/zabbix-agent2:alpine-latest

echo "Zabbix Docker environment deployed."
echo "Access Web UI:"
echo "http://<server-ip>:8080"
