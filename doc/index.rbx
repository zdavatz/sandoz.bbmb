#!/usr/bin/env ruby
# index.rbx -- bbmb.ch -- hwyss@ywesee.com

require 'sbsm/request'
require 'encoding/character/utf-8'

DRb.start_service('druby://localhost:0')

begin
	SBSM::Request.new(ENV["DRB_SERVER"]).process
rescue Exception => e
	$stderr << "Client Error: " << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
