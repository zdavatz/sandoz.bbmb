#!/usr/bin/env ruby
# Html::State::Viral::Customer -- sandoz.bbmb.ch -- 20.11.2007 -- hwyss@ywesee.com

require 'bbmb/html/state/viral/customer'
require 'bbmb/html/state/change_password'

module BBMB
  module Html
    module State
      module Viral
module Customer 
  def change_pass
    ChangePassword.new(@session, _customer)
  end
  unless(instance_methods.include?("__extension_zone_navigation__"))
    alias :__extension_zone_navigation__ :zone_navigation
  end
  def zone_navigation
    __extension_zone_navigation__.push(:change_pass)
  end
end
      end
    end
  end
end
