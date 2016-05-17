source 'https://rubygems.org'
gemspec

# gem 'bbmb', :path => '/opt/src/bbmb'
group :debugger do
	if RUBY_VERSION.match(/^1/)
		gem 'pry-debugger'
	else
		gem 'pry-byebug'
    gem 'pry-doc'
	end
end
