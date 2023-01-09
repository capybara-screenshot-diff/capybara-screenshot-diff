# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in capybara-screenshot-diff.gemspec
gemspec path: __dir__

gem "rake"

# Image processing libraries
gem "oily_png", platform: :ruby, git: "https://github.com/donv/oily_png", branch: "patch-2"
gem "ruby-vips", require: false

# Test
gem "minitest", require: false
gem "minitest-stub-const", require: false
gem "simplecov", require: false

# Capybara Server
gem "puma", RUBY_PLATFORM.include?("java") ? "< 6" : ">= 5", require: false

# Capybara Drivers
gem "cuprite", require: false
gem "selenium-webdriver", require: false
gem "webdrivers", require: false

group :tools do
  gem "standard", require: false
  gem "rbs", require: false, platform: :ruby
end
