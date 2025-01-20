FROM node:12.13.0-alpine AS builder

# Build Theme
WORKDIR /build/themes/yeldirium

ADD themes/yeldirium/package.json package.json
ADD themes/yeldirium/yarn.lock yarn.lock

RUN yarn install

ADD themes/yeldirium/ .

RUN npx webpack --mode production

# Build Site
WORKDIR /build

ADD package.json /build/package.json
ADD yarn.lock /build/yarn.lock

RUN yarn install

ADD source source
ADD _config.yml _config.yml

RUN npx hexo generate

# Build minimal Apache image
FROM httpd:2.4.62

# Install the OpenTelemetry httpd instrumentation. See https://github.com/open-telemetry/opentelemetry-cpp-contrib/tree/main/instrumentation/httpd
ADD https://github.com/open-telemetry/opentelemetry-cpp-contrib/releases/download/httpd%2Fv0.1.0/ubuntu-20.04_mod-otel.so.zip /tmp
RUN mv /tmp/ubuntu-20.04_mod-otel.so.zip /usr/local/apache2/modules/mod_otel.so.gz
RUN gzip -d /usr/local/apache2/modules/mod_otel.so.gz

ADD apache/opentelemetry.conf /usr/local/apache2/conf/extra/
ADD apache/httpd.conf /usr/local/apache2/conf/httpd.conf

COPY --from=builder /build/public /usr/local/apache2/htdocs
ADD apache/.htaccess /usr/local/apache2/htdocs/.htaccess
ADD static/* /usr/local/apache2/htdocs/
