FROM alpine:3.4

RUN apk update && apk add openssl
ADD /assets /assets

CMD /assets/default.sh