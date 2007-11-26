#!/usr/bin/env ruby
# Selenium::TestCustomers -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require "selenium/unit"

module BBMB
  module Selenium
class TestCustomers < Test::Unit::TestCase
  include Selenium::TestCase
  def test_customers
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    assert @selenium.is_text_present("1 bis 1 von 1")
    assert_equal "BBMB | Kunden", @selenium.get_title
    assert @selenium.is_text_present("Kundennr")
    assert @selenium.is_text_present("007")
    assert @selenium.is_text_present("PLZ")
    assert @selenium.is_text_present("7777")
    assert @selenium.is_text_present("Aktiviert")
  end
  def test_customers__filter
    customer1 = BBMB::Model::Customer.new('007')
    customer1.organisation = 'Test-Customer'
    customer1.plz = '7777'
    customer2 = BBMB::Model::Customer.new('010')
    customer2.organisation = 'Filter-Customer'
    customer2.plz = '7778'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer1, customer2]
    }
    user = login_admin
    assert @selenium.is_text_present("1 bis 2 von 2")
    assert_equal "BBMB | Kunden", @selenium.get_title
    assert @selenium.is_text_present("Test-Customer")
    assert @selenium.is_text_present("Filter-Customer")
    @selenium.type "//input[@name='filter']", "filter"
    @selenium.click "filter_button"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Kunden", @selenium.get_title
    assert !@selenium.is_text_present("Test-Customer")
    assert @selenium.is_text_present("Filter-Customer")
  end
  def test_customers__pager
    BBMB.config.pagestep = 1
    customer1 = BBMB::Model::Customer.new('007')
    customer1.organisation = 'Test-Customer 1'
    customer1.plz = '7777'
    customer2 = BBMB::Model::Customer.new('010')
    customer2.organisation = 'Test-Customer 2'
    customer2.plz = '7777'
    customer3 = BBMB::Model::Customer.new('011')
    customer3.organisation = 'Test-Customer 3'
    customer3.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer1, customer2, customer3]
    }
    user = login_admin
    assert @selenium.is_text_present("1 bis 1 >> von 3")
    assert_equal "BBMB | Kunden", @selenium.get_title
    assert @selenium.is_text_present("Test-Customer 1")
    assert !@selenium.is_element_present("link=<<")
    assert @selenium.is_element_present("link=>>")

    @selenium.click "link=>>"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("<< 2 bis 2 >> von 3")
    assert_equal "BBMB | Kunden", @selenium.get_title
    assert @selenium.is_text_present("Test-Customer 2")
    assert @selenium.is_element_present("link=<<")
    assert @selenium.is_element_present("link=>>")

    @selenium.click "link=>>"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("<< 3 bis 3 von 3")
    assert_equal "BBMB | Kunden", @selenium.get_title
    assert @selenium.is_text_present("Test-Customer 3")
    assert @selenium.is_element_present("link=<<")
    assert !@selenium.is_element_present("link=>>")
  end
end
  end
end
