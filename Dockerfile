FROM golang:alpine3.12 AS build

RUN apk add git && \
    git clone https://github.com/CodeMyst/pastemyst-autodetect.git /src

WORKDIR /src
RUN go build -o /usr/bin/pastemyst-autodetect .

FROM dlang2/dmd-ubuntu:2.096.1

COPY --from=build /usr/bin/pastemyst-autodetect /usr/bin/

RUN apt-get update && \
    apt-get install -y libssl-dev libscrypt-dev patch git

WORKDIR /app

RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT dub run
