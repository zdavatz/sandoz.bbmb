#!/usr/bin/env ruby
# Persistence::Test -- bbmb.ch -- 14.09.2006 -- hwyss@ywesee.com

require 'bbmb/model/customer'
require 'bbmb/model/product'
require 'bbmb/model/promotion'

class Object
  def meta_class; class << self; self; end; end
  def meta_eval &blk; meta_class.instance_eval &blk; end
end
module BBMB
  module Persistable
    def Persistable.append_features(mod)
      super
      mod.module_eval {
        alias :__test_initialize__ :initialize
        @instances = []
        def initialize(*args)
          __test_initialize__(*args)
          self.class.instances.push(self)
        end
        class << self
          attr_reader :instances
          def clear_instances
            @instances.clear
          end
          def index(*keys)
            index_suffix = keys.join('_and_')
            method_name = sprintf("find_by_%s", index_suffix)
            meta_eval {
              define_method(method_name) { |*vals| 
                @instances.find { |instance|
                  vals == keys.collect { |key| instance.send(key) } 
                }
              }
            }
          end
        end
      }
    end
  end
  module Model
    class Product
      include Persistable
      index :article_number
      index :ean13
      index :description
      index :pcode
    end
    class Customer
      include Persistable
      index :customer_id
      index :email
    end
  end
end
