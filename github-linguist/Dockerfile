FROM ruby:2-alpine3.13

RUN apk --update add --no-cache --virtual .build-deps \
    build-base cmake libc-dev \
    && apk add --no-cache curl git icu-dev jq openssl-dev \
    && gem install github-linguist \
    && apk del .build-deps

CMD ["github-linguist"]
