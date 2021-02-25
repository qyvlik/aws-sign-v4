FROM openresty/openresty:alpine

ENV APK_REPO=mirrors.aliyun.com

RUN sed -i "s/dl-cdn.alpinelinux.org/${APK_REPO}/g" /etc/apk/repositories

RUN apk add --no-cache curl perl

RUN opm get jkeys089/lua-resty-hmac

