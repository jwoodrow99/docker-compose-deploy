FROM node:18.15.0

WORKDIR /usr/src/app

ADD ./config/nginx/sites/node/ ./
RUN npm install

EXPOSE 9000

CMD ["npm", "run", "start"]
