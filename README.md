ODK Aggregate Server
====================


This repository contains the components necessary to create a basic Docker
container for [ODK Aggregate](https://docs.opendatakit.org/aggregate-intro/) 
 the official server that stores, analyzes, and presents [XForm](https://docs.opendatakit.org/form-design-intro/)
  survey data collected using [ODK Collect](https://docs.opendatakit.org/collect-intro/) 
  or other [OpenRosa-compliant applications](https://docs.opendatakit.org/openrosa/).

The image is based on a Tomcat6 image, and bundles an ODK Aggregate v1.6.1.


Environment variables
---------------------

    ODK_HOSTNAME=
    ODK_ADMIN_USER=
    ODK_ADMIN_USERNAME=admin
    ODK_AUTH_REALM=ODK Aggregate
    ODK_PORT=8080
    ODK_PORT_SECURE=8443
    DATABASE_URL=jdbc:postgresql://db:5432/odk
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=    
    FLYWAY=https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.0.3/flyway-commandline-4.0.3-linux-x64.tar.gz
    ODK=https://github.com/opendatakit/aggregate/releases/download/v1.6.1/ODK-Aggregate-v1.6.1-Linux-x64.run


Build
-----

Image can be built with the classic docker command

    docker build -t unicef/odk:dev .
    
or more easily using the provided `Makefile` that creates a local cache and add some 

    make build
    
    
#### Makefile cheatsheet 

   - `build`: build docker image `unicef/odk:dev` image
   - `run`  : run the server. Available on port `8080`
   - `shell`: run the container (not the server) and open a bash shell
   - `push` : push the image to Docker HUB.
   - `cache`: copy required files in the local `cache` folder. Intended to be used for multiple builds 
   - `debug`: map some directories to host's folder, to faciltate development and debugging.
  
#### docker-composer

a `docker-composer.yml` is provided. 
 

  
