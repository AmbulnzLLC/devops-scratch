FROM node:latest
MAINTAINER Jake Bladt <jake@ambulnz.com>
RUN mkdir -p /usr/src/app
COPY ./src /usr/src/app
WORKDIR /usr/src/app
RUN npm install

EXPOSE 8080
CMD [ "npm", "start" ]
