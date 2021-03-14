FROM ruby:2.7.2-alpine

RUN apk add --update alpine-sdk sqlite-dev

ENV APP_HOME /myapp

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

ENV RACK_ENV=development

RUN gem install bundler:2.2.13
