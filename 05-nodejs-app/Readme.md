## exo 01 - create a nodejs application
from the files given in [04-problems/exercices/exo01](04-problems/exercices/exo01)
this application can be easily run using
```bash
npm install
```
that will generate package.lock

and then 
```bash
npm start
```
to run the server

The application will be available on [http://localhost:8080](http://localhost:8080)

## exo 01-1 - Dockerfile
Create a node image in order to run this node application.

The image will encapsulate npm packages.

source code of the application will be stored in `/usr/src/app` directory

**Hint 1** be careful to the build context of the image

**Hint 2** try to use COMMAND directive, so when the container is started, 
the server also is automatically started

build your image using `docker build`

## exo01-2 - launch the container
use docker exec to launch the container

## exo01-3 - user docker-compose
even if there is no real advantage to use it, try as an exercise to launch 
the container using a docker-compose.yml file

## exo01-4 - port configurable 
with this version the port will be configurable using an environment variable
**Hint 1** variables can be defined in .env file if using docker-compose.yml
**Hint 2** or variables can be exported directly from the bash that is launching the container
```bash
export HOST_NODE_SERVER_PORT=8081
```

## exo01-5 - externalize source code
Now we don't want source code and node packages to be stored in the docker image.
change the Dockerfile and use path mapping in order to externalize the source code.

