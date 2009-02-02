#!/usr/bin/env ruby
# Util::CsvImporter -- sandoz.bbmb.ch -- 19.11.2007 -- hwyss@ywesee.com

require 'bbmb/model/customer'
require 'bbmb/util/mail'
require 'encoding/character/utf-8'
require 'iconv'
require 'yus/entity'

module BBMB
  module Util
class CsvImporter
  def import(io, persistence=BBMB.persistence)
    count = 0
    iconv = Iconv.new('utf-8', 'latin1')
    io.each { |line|
      line = u(iconv.iconv(line))
      record = line.split("\t")
      if(object = import_record(record))
        persistence.save(object)
      end
      count += 1
    }
    postprocess(persistence)
    count
  end
  def postprocess(persistence=BBMB.persistence)
  end
  def string(str)
    str = str.to_s.strip
    str.gsub(/\s+/, ' ') unless str.empty? 
  end
end
class CustomerImporter < CsvImporter
  CUSTOMER_MAP = {
    1   =>  :ean13,
    3   =>  :title,
    4   =>  :firstname,
    5   =>  :lastname,
    6   =>  :organisation,
    8   =>  :address1,
    9   =>  :plz,
    10  =>  :city,
    11  =>  :phone_business,
    12  =>  :fax,
  }  
  def import_record(record)
    customer_id = string(record[0])
    ean13 = string(record[1])
    return unless(/^\d+$/.match(customer_id))
    customer = Model::Customer.find_by_customer_id(customer_id)
    if customer.nil? && !ean13.to_s.empty? \
      && (customer = Model::Customer.find_by_ean13(ean13))
      customer.customer_id = customer_id
    end
    customer ||= Model::Customer.new(customer_id)
    CUSTOMER_MAP.each { |idx, name|
      unless customer.protects? name
        customer.send("#{name}=", string(record[idx]))
      end
    }
    customer
  rescue Yus::DuplicateNameError => err
    @duplicates.push(err)
    nil
  end
end
class ProductImporter < CsvImporter
  PRODUCT_MAP = {
    1   =>  :description_de,
    2   =>  :description_fr,
    3   =>  :ean13,
    4   =>  :pcode,    
    5   =>  :price,
  }
  def initialize
    super
    @active_products = {}
  end
  def import_record(record)
    article_number = string(record[0])
    return unless(/^\d+$/.match(article_number))
    @active_products.store article_number, true
    product = Model::Product.find_by_article_number(article_number) \
      || Model::Product.new(article_number)
    PRODUCT_MAP.each { |idx, name|
      value = string(record[idx])
      writer = "#{name}="
      case name
      when :description_de
        product.description.de = value
      when :description_fr
        product.description.fr = value
      else
        product.send(writer, value)
      end
    }
    product
  end
  def postprocess(persistence)
    return if(@active_products.empty?)
    deletables = []
    persistence.all(BBMB::Model::Product) { |product|
      unless(@active_products.include?(product.article_number))
        deletables.push product
      end
    }
    persistence.all(BBMB::Model::Customer) { |customer|
      [customer.current_order, customer.favorites].each { |order|
        deletables.each { |product|
          order.add(0, product)
        }
      }
    }
    persistence.delete(*deletables) unless(deletables.empty?)
  end
end
  end
end
