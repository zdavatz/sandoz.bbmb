#\ -w -p 8010
# 8010 is the port used to serve
# vim: ai ts=2 sts=2 et sw=2 ft=ruby
begin
  require 'pry'
rescue LoadError
end
lib_dir = File.expand_path(File.join(File.dirname(__FILE__), 'lib').untaint)
$LOAD_PATH << lib_dir
$stdout.sync = true

require 'bbmb/config'
[ File.join(Dir.pwd, 'etc', 'config.yml'),
].each do |config_file|
  if File.exist?(config_file)
    puts "BBMB.config.load from #{config_file}"
    BBMB.config.load (config_file)
    break
  end
end
ENV['SERVER_PORT'] =  BBMB.config.server_port.to_s if BBMB.config.respond_to?(:server_port)

require 'bbmb/html/util/validator'
require 'bbmb/util/app'
require 'rack'
require 'rack/static'
require 'rack/show_exceptions'
require 'rack'
require 'sbsm/logger'
require 'bbmb/util/rack_interface'
require 'webrick'
SBSM.logger= ChronoLogger.new(BBMB.config.log_pattern)
# We must load (not require) the CSV-Importer from Sandoz
sandoz_importer = File.join(lib_dir, 'bbmb/util/csv_importer.rb')
load sandoz_importer
SBSM.info msg = "Loading #{sandoz_importer}"
use Rack::CommonLogger, SBSM.logger
use(Rack::Static, urls: ["/doc/"])
use Rack::ContentLength
SBSM.info "Starting Rack::Server BBMB::BBMB::Util.new with log_pattern #{BBMB.config.log_pattern}"

$stdout.sync = true
VERSION = `git rev-parse HEAD`
puts msg = "Used version: sbsm #{SBSM::VERSION}, bbmb #{BBMB::VERSION} sandoz #{VERSION}"
SBSM.logger.info(msg)

my_app = BBMB::Util::RackInterface.new(app: BBMB::Util::App.new)
app = Rack::ShowExceptions.new(Rack::Lint.new(my_app))
run app
