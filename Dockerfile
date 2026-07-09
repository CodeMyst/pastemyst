# build the language autodetect helper
FROM golang:alpine3.12 AS autodetect

RUN apk add --no-cache git && \
    git clone https://github.com/CodeMyst/pastemyst-autodetect.git /src

WORKDIR /src
RUN go build -o /pastemyst-autodetect .

# compile pastemyst
FROM dlang2/dmd-ubuntu:2.096.1 AS build

RUN apt-get update && \
    apt-get install -y libssl-dev libscrypt-dev patch git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

# the git describe result is baked into a VERSION file so the runtime image
# doesn't need git or the .git directory
RUN git config --global --add safe.directory /app && \
    git describe --tags > VERSION

# release build; produces bin/pastemyst.
RUN DC=dmd dub build -b release

# runtime image: only the compiled binary + the files it needs at runtime
FROM ubuntu:20.04

# runtime deps: openssl + libscrypt (linked), diffutils + patch (paste diff/history
# are computed by shelling out to `diff`/`patch` at runtime, see util/diff.d)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libssl1.1 libscrypt-dev diffutils patch ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=autodetect /pastemyst-autodetect /usr/bin/pastemyst-autodetect
COPY --from=build /app/bin/pastemyst /app/bin/pastemyst
COPY --from=build /app/VERSION /app/VERSION
COPY --from=build /app/data /app/data
COPY --from=build /app/public /app/public

# markdown pages rendered at runtime from cwd (/app)
COPY --from=build /app/CHANGELOG.md /app/CHANGELOG.md
COPY --from=build /app/LEGAL.md /app/LEGAL.md
COPY --from=build /app/pastry.md /app/pastry.md
COPY --from=build /app/DONATE.md /app/DONATE.md

# runtime-writable dirs (contents are gitignored, so they aren't in the build
# context): transient download zips, persisted avatars mountpoint, error logs
RUN mkdir -p /app/public/zips /app/public/assets/avatars /app/logs

EXPOSE 5000

ENTRYPOINT ["/app/bin/pastemyst"]
