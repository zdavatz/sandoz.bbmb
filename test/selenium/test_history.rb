#!/usr/bin/env ruby
# Selenium::TestHistory -- bbmb.ch -- 05.10.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'selenium/unit'

module BBMB
  module Selenium
class TestHistory < Test::Unit::TestCase
  include Selenium::TestCase
  def test_history
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    product1 = BBMB::Model::Product.new('1')
    product1.description.de = "Product 1"
    product1.price = Util::Money.new(11.10)
    product2 = BBMB::Model::Product.new('2')
    product2.description.de = "Product 2"
    product2.price = Util::Money.new(12.20)
    product3 = BBMB::Model::Product.new('3')
    product3.description.de = "Product 3"
    product3.price = Util::Money.new(13.30)
    product4 = BBMB::Model::Product.new('2')
    product4.description.de = "Product 2"
    product4.price = Util::Money.new(10.00)
    order = customer.current_order
    order.add(2, product1)
    order.add(3, product2)
    customer.commit_order!
    order = customer.current_order
    order.add(5, product4)
    order.add(7, product3)
    customer.commit_order!
    user = login_admin
    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Kunde", @selenium.get_title

    @selenium.click "link=Umsatz"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Umsatz", @selenium.get_title
    assert_equal "1", @selenium.get_text("//tr[2]/td[1]")
    assert_equal "2", @selenium.get_text("//tr[2]/td[2]")
    assert_equal "Product 1", @selenium.get_text("//tr[2]/td[3]")
    assert_equal "11.10", @selenium.get_text("//tr[2]/td[4]")
    assert_equal "22.20", @selenium.get_text("//tr[2]/td[5]")
    assert_equal "2", @selenium.get_text("//tr[3]/td[1]")
    assert_equal "8", @selenium.get_text("//tr[3]/td[2]")
    assert_equal "Product 2", @selenium.get_text("//tr[3]/td[3]")
    assert_equal "10.00 bis 12.20", @selenium.get_text("//tr[3]/td[4]")
    assert_equal "86.60", @selenium.get_text("//tr[3]/td[5]")
    assert_equal "1", @selenium.get_text("//tr[4]/td[1]")
    assert_equal "7", @selenium.get_text("//tr[4]/td[2]")
    assert_equal "Product 3", @selenium.get_text("//tr[4]/td[3]")
    assert_equal "13.30", @selenium.get_text("//tr[4]/td[4]")
    assert_equal "93.10", @selenium.get_text("//tr[4]/td[5]")
    assert @selenium.is_text_present("Totalumsatz: 201.90")

    ## sort the result according to quantity
    @selenium.click "link=Menge"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Umsatz", @selenium.get_title
    assert_equal "1", @selenium.get_text("//tr[2]/td[1]")
    assert_equal "2", @selenium.get_text("//tr[2]/td[2]")
    assert_equal "Product 1", @selenium.get_text("//tr[2]/td[3]")
    assert_equal "11.10", @selenium.get_text("//tr[2]/td[4]")
    assert_equal "22.20", @selenium.get_text("//tr[2]/td[5]")
    assert_equal "1", @selenium.get_text("//tr[3]/td[1]")
    assert_equal "7", @selenium.get_text("//tr[3]/td[2]")
    assert_equal "Product 3", @selenium.get_text("//tr[3]/td[3]")
    assert_equal "13.30", @selenium.get_text("//tr[3]/td[4]")
    assert_equal "93.10", @selenium.get_text("//tr[3]/td[5]")
    assert_equal "2", @selenium.get_text("//tr[4]/td[1]")
    assert_equal "8", @selenium.get_text("//tr[4]/td[2]")
    assert_equal "Product 2", @selenium.get_text("//tr[4]/td[3]")
    assert_equal "10.00 bis 12.20", @selenium.get_text("//tr[4]/td[4]")
    assert_equal "86.60", @selenium.get_text("//tr[4]/td[5]")
    assert @selenium.is_text_present("Totalumsatz: 201.90")

    ## sort the result according to quantity - reversed
    @selenium.click "link=Menge"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Umsatz", @selenium.get_title
    assert_equal "2", @selenium.get_text("//tr[2]/td[1]")
    assert_equal "8", @selenium.get_text("//tr[2]/td[2]")
    assert_equal "Product 2", @selenium.get_text("//tr[2]/td[3]")
    assert_equal "10.00 bis 12.20", @selenium.get_text("//tr[2]/td[4]")
    assert_equal "86.60", @selenium.get_text("//tr[2]/td[5]")
    assert_equal "1", @selenium.get_text("//tr[3]/td[1]")
    assert_equal "7", @selenium.get_text("//tr[3]/td[2]")
    assert_equal "Product 3", @selenium.get_text("//tr[3]/td[3]")
    assert_equal "13.30", @selenium.get_text("//tr[3]/td[4]")
    assert_equal "93.10", @selenium.get_text("//tr[3]/td[5]")
    assert_equal "1", @selenium.get_text("//tr[4]/td[1]")
    assert_equal "2", @selenium.get_text("//tr[4]/td[2]")
    assert_equal "Product 1", @selenium.get_text("//tr[4]/td[3]")
    assert_equal "11.10", @selenium.get_text("//tr[4]/td[4]")
    assert_equal "22.20", @selenium.get_text("//tr[4]/td[5]")
    assert @selenium.is_text_present("Totalumsatz: 201.90")

  end
end
  end
end
