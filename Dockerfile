FROM ruby:2.5
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir /foreign_science_tech
WORKDIR /foreign_science_tech
COPY Gemfile /foreign_science_tech/Gemfile
COPY Gemfile.lock /foreign_science_tech/Gemfile.lock
RUN bundle install
COPY . /foreign_science_tech

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
RUN RAILS_ENV=production bundle exec rake assets:precompile --trace
EXPOSE 3000

# Start the main process.
# CMD ["rails", "server", "-b", "0.0.0.0"]