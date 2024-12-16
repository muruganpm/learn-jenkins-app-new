
FROM node:18-alpine

WORKDIR /app

RUN apk update && apk add --no-cache \
    git \
    nodejs \
    npm
RUN git clone https://github.com/muruganpm/learn-jenkins-app-new.git .

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
~

