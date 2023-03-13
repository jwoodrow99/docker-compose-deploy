FROM ruby:3.2.1

WORKDIR /usr/src/app

ADD ./config/nginx/sites/ruby/ ./

EXPOSE 9000

CMD ["ruby", "./index.rb"]
