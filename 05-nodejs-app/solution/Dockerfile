FROM node:10

# Create app directory
WORKDIR /usr/src/app

# where the source code is available
ARG SRC_DIR=../exercise/src

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY "${SRC_DIR}/package*.json" ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# Bundle app source
COPY ${SRC_DIR} .

EXPOSE 8080
CMD [ "npm", "start" ]