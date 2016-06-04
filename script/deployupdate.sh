#!/bin/bash --login
cd /var/www/cityvoice/code
source ~/.bashrc
rvm use ruby-2.1.7
bundle install --deployment --without development test
bundle exec rake assets:precompile db:migrate RAILS_ENV=production
bundle exec rake import:locations
bundle exec rake import:questions