FROM node:18

WORKDIR /usr/src/app

ENV REDIS_ADDRESS=redis

ENV REDIS_PORT=6379

ENV APP_PORT=8080

COPY . .

RUN npm install -g npm@9.8.1
RUN npm ci

EXPOSE 8080

CMD [ "node", "src/app.js" ] 
