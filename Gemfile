
gem "rails", "3.2.13"

gem 'activerecord-intersys-adapter', :git => "git@github.com:salman-4w/activerecord-intersys-adapter.git", :branch => "main"
# TODO - upgrade prawn and remove prawn-layout gem
gem "prawn", "0.8.4"
gem "prawn-layout", "0.8.4" # adds tables to prawn
gem "prawnto_2", require: "prawnto"
gem "airbrake", "~> 3.1.2"
gem "resque"
gem "resque_mailer"


group :assets do
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "uglifier", ">= 1.0.3"
end

group :development do
  gem "capistrano"
  gem "capistrano-ext"
  gem "pry-rails"
  gem "awesome_print"
  gem "interactive_editor"
  gem "mailcatcher"
end

group :development, :test do
  gem "guard"
  gem "guard-test"
end
