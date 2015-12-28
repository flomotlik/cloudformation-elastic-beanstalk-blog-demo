FROM ruby:2.2.4

RUN gem install bundler

WORKDIR /app

ADD Gemfile ./Gemfile
RUN bundle install

ADD . ./

EXPOSE 4567
CMD ["ruby", "./app.rb", "-o", "0.0.0.0"]
