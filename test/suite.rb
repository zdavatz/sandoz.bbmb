#!/usr/bin/env ruby
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com 

here = File.expand_path(File.dirname(__FILE__))
$: << here

require 'find'

Find.find(here) do |file|
  if /test_.*\.rb$/o.match(file)
    next if /selenium/i.match(file)
    require file
  end
end

