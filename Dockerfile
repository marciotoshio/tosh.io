FROM ruby:2.3.1-alpine

RUN apk add --update alpine-sdk sqlite-dev

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

ENV RACK_ENV=development

COPY . /usr/src/app

CMD ["rackup", "--host", "0.0.0.0"]
