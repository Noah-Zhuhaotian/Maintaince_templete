#!/bin/bash

set -e

echo "Starting deployment with backup..."

# Set variables
WAR_FILE=$(ls /home/ec2-user/*.war | head -n 1)
TOMCAT_DIR="/opt/tomcat/latest"
WEBAPPS_DIR="$TOMCAT_DIR/webapps"
BACKUP_DIR="/home/ec2-user/backup"

# create backup directory if it doesn't exist
echo "Ensuring backup directory exists..."
mkdir -p $BACKUP_DIR

# Stop Tomcat
echo "Stopping Tomcat..."
sudo systemctl stop tomcat || sudo systemctl stop tomcat9 || sudo systemctl stop tomcat8 || true

# Backup existing ROOT.war and ROOT directory
if [ -f "$WEBAPPS_DIR/ROOT.war" ]; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    echo "Backing up existing ROOT.war..."
    sudo cp $WEBAPPS_DIR/ROOT.war $BACKUP_DIR/ROOT_$TIMESTAMP.war
fi

if [ -d "$WEBAPPS_DIR/ROOT" ]; then
    echo "Backing up existing ROOT directory..."
    sudo cp -r $WEBAPPS_DIR/ROOT $BACKUP_DIR/ROOT_$TIMESTAMP
fi

# Clean up old deployment
echo "Cleaning old deployment..."
sudo rm -rf $WEBAPPS_DIR/ROOT
sudo rm -f $WEBAPPS_DIR/ROOT.war

# Deploy new WAR file
echo "Deploying new WAR file..."
sudo cp $WAR_FILE $WEBAPPS_DIR/ROOT.war

# Start Tomcat
echo "Starting Tomcat..."
sudo systemctl start tomcat || sudo systemctl start tomcat9 || sudo systemctl start tomcat8

echo "Deployment completed successfully."
