# Aim
Install VueJs/Webpack stack using node image, server part is using nginx

## Steps to Run

```bash
# Navigate into the exercise directory 
cd "${TUTO_BASE_DIR}/08-VueJs-stack/solution/part02-webpack"
# Build Docker Images
docker-compose build
# Run the stack :)
docker-compose up
```

if you receive the error `ERROR: for webserver  Cannot start service server: driver failed programming external connectivity on endpoint webserver (f3a992da471197522c32c008d055bf896ce33131bda433507b3e157899b68f06): Bind for 0.0.0.0:80 failed: port is already allocated`.
Then you need to create a .env file to change the web server port
 ```bash
 # go to the exercise directory
 cd "${TUTO_BASE_DIR}/08-VueJs-stack/solution/part02-webpack"
 # create .env file, change here the port if needed
 echo "HOST_SERVER_PORT=8080" > .env
 ```

Be patient and wait for all for all of the NPM warnings to finish - this will only happen once. 

Your app should now be running on: [http://localhost:8080](my app)

## Architecture

There are 2 parts to this dockerized Vue app: 
* Frontend (Vue), 
* Backend (nginx)

The frontend is in the 'client' folder, backend will be in the 'server' folder.

In the file `.docker/client/Dockerfile`, we have added `npm install -g @vue/cli`

## Generate vue application

first connect to the node container
```bash
winpty docker exec -it -u node node sh
```

Then create you vue application
```bash
(cd data && vue create .)
```
