#! /bin/sh
bundle exec sidekiq  -C config/sidekiq.yml -d #-e production