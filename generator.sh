#!/bin/bash

####################################
##
##  Generateur de docker-compose
##
####################################

## Variables ####################################################

DIR="${HOME}/generator"
USER_SCRIPT=${USER}

## Functions ####################################################

help(){

echo "USAGE :

  ${0##*/} [-h] [--help]
  
  Options :

    -h, --help : aides

    -p, --postgres : lance une instance postgres

    -m, --mysql : lance une instance MySQL

    -i, --ip : affichage des ip

"
}

ip() {
for i in $(docker ps -q); do docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} - {{.Name}}" $i;done
}

parser_options(){

case $@ in    
    -h|--help)
      help
    ;;

    -p|--postgres)
      postgres
    ;;

    -m|--mysql)
      mysql
    ;;
    -mn|--mongo)
    mongo
    ;;

    *)
        echo "invalide option, launch -h or --help"
esac
}

postgres(){

echo ""
echo "Installation of a postgres instance..."
echo ""
echo "1 - datas repository creation"
mkdir -p $DIR/postgres
echo ""
echo "
version: '3.7'
services:
  postgres:
    image: postgres:latest
    container_name: postgres
    environment:
    - POSTGRES_USER=myuser
    - POSTGRES_PASSWORD=password
    - POSTGRES_DB=mydb
    ports:
    - 5432:5432
    volumes:
    - postgres_data:/var/lib/postgres
    networks:
    - generator
volumes:
  postgres_data:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: ${DIR}/postgres
networks:
  generator:
    driver: bridge
    ipam:
      config:
        - subnet: 192.169.0.0/24


" >$DIR/docker-compose-postgres.yml

echo "2 - Run de l'instance..."
docker-compose -f $DIR/docker-compose-postgres.yml  up -d

echo ""
echo "
Credentials :
    - PORT : 5432
    - POSTGRES_USER: myuser
    - POSTGRES_PASSWORD: password
    - POSTGRES_DATABASE: mydb

Command : psql -h <ip> -u myuser -d mydb
"
}

mysql(){

echo ""
echo "Installation of a MySQL instance..."
echo ""
echo "1 - datas repository creation.."
mkdir -p $DIR/mysql
echo ""
echo "
version: '3.7'
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    environment:
    - MYSQL_ROOT_PASSWORD=password
    - MYSQL_DATABASE=mydb
    - MYSQL_USER=myuser
    - MYSQL_PASSWORD=password
    ports:
    - 3306:3306
    volumes:
    - mysql_data:/var/lib/mysql
    networks:
    - generator
volumes:
  mysql_data:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: ${DIR}/mysql
networks:
  generator:
    driver: bridge
    ipam:
      config:
        - subnet: 192.169.0.0/24
" >$DIR/docker-compose-mysql.yml

echo "2 - Run de l'instance..."
docker-compose -f $DIR/docker-compose-mysql.yml  up -d

echo ""
echo "
Credentials :
    - PORT : 3306
    - MYSQL_ROOT_PASSWORD: password
    - MYSQL_DATABASE: mydb
    - MYSQL_USER: myuser
    - MYSQL_PASSWORD: password

Command : mysql -h <ip> -u myuser -p mydb
"
}
mongo(){

  echo ""
  echo "Installing MongoDB instance..."
  echo ""
  echo "1 - Creating data repository"
  mkdir -p $DIR/mongo
  echo ""
  echo "
version: '3.7'
services:
  mongo:
    image: mongo:latest
    container_name: mongo
    ports:
      - 27017:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=admin123
    volumes:
      - mongo_data:/data/db
    networks:
      - generator
volumes:
  mongo_data:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: ${DIR}/mongo
networks:
  generator:
    driver: bridge
    ipam:
      config:
        - subnet: 192.169.0.0/24
" > $DIR/docker-compose-mongo.yml

  echo "2 - Running the instance..."
  docker-compose -f $DIR/docker-compose-mongo.yml up -d

  echo ""
  echo "
Credentials :
    - PORT : 27017
    - Username: admin
    - Password: admin123

Command : mongo --host <ip> -u admin -p admin123 --authenticationDatabase admin
"
}

## Execute ######################################################

parser_options $@
ip



#docker run --rm --name maven -v /var/lib/maven/:/root/.m2 -v $(pwd):/usr/src/mymaven --network generator_generator -w /usr/src/mymaven maven:3.8.3-jdk-17 mvn -B clean test

#docker run --rm --name maven -v /var/lib/maven/:/root/.m2 -v $(pwd):/usr/src/mymaven --network generator_generator -w /usr/src/mymaven maven:3.8.3-jdk-17 mvn -B clean install
 #docker run -d --name eduhousing --network generator_generator -v C:/app/EduHousing/src/main/resources/application.yml:/etc/application.yml -p 8081:8081 version:1.0 java -jar /jar/EduHousing-0.0.1-SNAPSHOT.jar --spring.config.location=file:/etc/application.yml
