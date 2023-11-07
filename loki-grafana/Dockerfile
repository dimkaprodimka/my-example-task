FROM golang:1.20

WORKDIR /usr/src/app

ENV PORT=8080
ENV LOG_PATH=/var/log/

COPY . .

RUN go mod download && go mod verify 
RUN go build ./
EXPOSE 8080

CMD [ "/bin/sh", "-c", "go run webapp > /var/log/app.log 2>&1" ]