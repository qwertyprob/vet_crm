source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "active_model_serializers", "~> 0.10.16"
gem "rack-cors", "~> 2.0"
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "lograge"
gem "bootsnap", require: false
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[windows jruby]
gem "image_processing", "~> 2.0"
gem "tailwindcss-rails", "~> 4.6"
gem "devise"

group :development, :test do
  gem "dotenv-rails", "~> 3.2"
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "rubocop-yard"
  gem "ruby-lsp-rspec", require: false
end

group :test do
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
end

gem "ruby_ui", "~> 1.6", group: :development, require: false

gem "phlex-rails", "~> 2.4"

gem "tailwind_merge", "~> 1.5"
