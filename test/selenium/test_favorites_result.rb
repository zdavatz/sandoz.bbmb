#!/usr/bin/env ruby
# Selenium::TestFavoritesResult -- bbmb.ch -- 05.10.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require "selenium/unit"

module BBMB
  module Selenium
class TestFavoritesResult < Test::Unit::TestCase
  include Selenium::TestCase
  def test_favorites_result__empty
    user = login_customer
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      []
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search_favorites"
    @selenium.wait_for_page_to_load "30000"

    assert @selenium.is_text_present("Suchresultat: 0 Produkte gefunden")
    assert @selenium.is_element_present("//input[@type='text' and @name='query']")
    assert !@selenium.is_element_present("//input[@type='submit' and @name='order_product']")
  end
  def test_favorites_result__1
    user = login_customer
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title

    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(12.50)
    flexstub(Model::Product).should_receive(:search_by_description).times(1).and_return { 
      |query|
      assert_equal 'product', query
      [product]
    }
    @selenium.type "query", "product"
    @selenium.click "document.search.search_favorites"
    @selenium.wait_for_page_to_load "30000"

    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_text_present("Suchresultat: 1 Produkt gefunden")
    assert @selenium.is_element_present("//input[@type='text' and @name='query']")
    assert !@selenium.is_element_present("//input[@type='submit' and @name='order_product']")
    assert @selenium.is_element_present("//input[@name='quantity[12345]']")
    assert_equal '0', @selenium.get_value("//input[@name='quantity[12345]']")
    assert !@selenium.is_text_present("im Rückstand")
  end
  def test_favorites_result__backorder
    user = login_customer
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title

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
    @selenium.click "document.search.search_favorites"
    @selenium.wait_for_page_to_load "30000"

    assert_equal "BBMB | Suchen", @selenium.get_title
    assert @selenium.is_text_present("Suchresultat: 1 Produkt gefunden")
    assert @selenium.is_text_present("im Rückstand")
  end
end
  end
end
