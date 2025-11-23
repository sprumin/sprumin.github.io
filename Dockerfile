FROM jekyll/jekyll:4.3.2

WORKDIR /srv/jekyll

COPY . /srv/jekyll

RUN bundle install
