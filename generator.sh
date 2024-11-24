#!/bin/bash

MYSQL_ROOT_PASSWORD=$1
MONGO_USERNAME=$2
MONGO_PASSWORD=$3

while getopts "mn" opt; do
  case $opt in
    m) 
      echo "Starting MySQL container..."
      docker run -d --name mysql-container \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
        -p 3306:3306 \
        mysql:latest
      ;;
    n)
      echo "Starting MongoDB container..."
      docker run -d --name mongo-container \
        -e MONGO_INITDB_ROOT_USERNAME=$MONGO_USERNAME \
        -e MONGO_INITDB_ROOT_PASSWORD=$MONGO_PASSWORD \
        -p 27017:27017 \
        mongo:latest
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
done
