
FROM alpine:latest
LABEL maintainer="Erick Otenyo <erick.otenyo@igad.int>"
ARG NAME=nrt-deploy
ENV NAME ${NAME}

RUN apk update
RUN apk add --no-cache dcron git docker

RUN mkdir -p /opt/$NAME/
WORKDIR /opt/$NAME/

COPY entrypoint.sh .
COPY .env .
RUN chmod +x entrypoint.sh
RUN touch /var/log/cron

CMD sh entrypoint.sh && crond -l 7 && tail -f /var/log/cron