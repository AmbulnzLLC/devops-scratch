FROM node:latest
MAINTAINER Jake Bladt <jake@ambulnz.com>
RUN mkdir -p /usr/src/app
COPY ./src /usr/src/app
WORKDIR /usr/src/app
RUN npm install

EXPOSE 80
CMD [ "npm", "start" ]
