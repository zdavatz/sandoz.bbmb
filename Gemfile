source 'https://rubygems.org'

  gem 'bbmb', '>= 2.2.6'

group :test do
  gem 'bundler'
  gem 'simplecov'
  gem 'rake'
  gem 'flexmock'
  gem 'test-unit'
  gem 'minitest'
  gem 'rspec'
end

group :debugger do
	if RUBY_VERSION.match(/^1/)
		gem 'pry-debugger'
	else
		gem 'pry-byebug'
    gem 'pry-doc'
	end
end
