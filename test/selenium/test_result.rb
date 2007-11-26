#!/usr/bin/env ruby
# Selenium::TestResult -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'selenium/unit'

module BBMB
  module Selenium
class TestResult < Test::Unit::TestCase
  include Selenium::TestCase
  def test_result__empty
    user = login_customer
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      []
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_text_present("Suchresultat: 0 Produkte gefunden")
    assert @selenium.is_element_present("//input[@type='text' and @name='query']")
    assert !@selenium.is_element_present("//input[@type='submit' and @name='order_product']")
  end
  def test_result__1
    user = login_customer
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(12.50)
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      [product]
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_text_present("Suchresultat: 1 Produkt gefunden")
    assert @selenium.is_element_present("//input[@type='text' and @name='query']")
    assert @selenium.is_element_present("//input[@type='submit' and @name='order_product']")
    assert @selenium.is_element_present("//input[@name='quantity[12345]']")
    assert_equal '0', @selenium.get_value("//input[@name='quantity[12345]']")
    assert !@selenium.is_text_present("im Rückstand")
  end
  def test_result__order
    BBMB.persistence.should_ignore_missing
    user = login_customer
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(11.50)
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      [product]
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_element_present("//input[@name='quantity[12345]']")
    assert_equal '0', @selenium.get_value("//input[@name='quantity[12345]']")
    @selenium.type "quantity[12345]", "15"
    @selenium.click "document.products.order_product"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_element_present("link=product - a description")
    assert @selenium.is_text_present("11.50")
    assert @selenium.is_text_present("172.50")
  end
  def test_result__backorder
    user = login_customer
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(12.50)
    product.backorder = true
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      [product]
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_text_present("Suchresultat: 1 Produkt gefunden")
    assert @selenium.is_text_present("im Rückstand")
  end
  def test_result__sort
    user = login_customer
    product1 = Model::Product.new('12345')
    product1.description.de = 'product 1'
    product1.price = Util::Money.new(12.50)
    product2 = Model::Product.new('12345')
    product2.description.de = 'product 2'
    product2.price = Util::Money.new(10.50)
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      [product1, product2]
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_text_present("Suchresultat: 2 Produkte gefunden")
    assert_equal 'product 1', @selenium.get_text("//tr[2]/td[2]")
    assert_equal 'product 2', @selenium.get_text("//tr[4]/td[2]")

    @selenium.click "link=Preis"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Suchresultat: 2 Produkte gefunden")
    assert_equal 'product 2', @selenium.get_text("//tr[2]/td[2]")
    assert_equal 'product 1', @selenium.get_text("//tr[4]/td[2]")

    @selenium.click "link=Preis"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Suchresultat: 2 Produkte gefunden")
    assert_equal 'product 1', @selenium.get_text("//tr[2]/td[2]")
    assert_equal 'product 2', @selenium.get_text("//tr[4]/td[2]")
  end
  def test_result__has_ordered_products
    BBMB.persistence.should_ignore_missing
    user = login_customer
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(11.50)
    @customer.current_order.add(5, product)
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      [product]
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_element_present("//input[@name='quantity[12345]']")
    assert_equal '5', @selenium.get_value("//input[@name='quantity[12345]']")
    @selenium.type "quantity[12345]", "trigger an error!"
    @selenium.click "document.products.order_product"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_element_present("//input[@name='quantity[12345]']")
    assert_equal '5', @selenium.get_value("//input[@name='quantity[12345]']")
    @selenium.type "quantity[12345]", "10"
    @selenium.click "document.products.order_product"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert_equal(10, @customer.current_order.quantity(product))
  end
end
  end
end
