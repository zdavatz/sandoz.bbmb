#!/usr/bin/env ruby
# Selenium::TestOrders -- bbmb.ch -- 05.10.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require 'selenium/unit'

module BBMB
  module Selenium
class TestOrders < Test::Unit::TestCase
  include Selenium::TestCase
  def setup_customer
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
    order = customer.current_order
    order.add(2, product1)
    order.add(3, product2)
    order.priority = 41
    order.shipping = 50
    order.reference = "Réf. N°"
    order.comment = "Freetext"
    customer.commit_order!
    order = customer.current_order
    order.add(5, product2)
    order.add(7, product3)
    customer.commit_order!
    customer
  end
  def test_archive__admin
    customer = setup_customer
    user = login_admin
    @selenium.click "link=Test-Customer"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Kunde", @selenium.get_title

    assert @selenium.is_element_present("link=Sfr. 262.90")
    @selenium.click "link=Sfr. 262.90"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Archiv", @selenium.get_title
    assert @selenium.is_text_present(Date.today.strftime('%d.%m.%Y'))
    assert @selenium.is_text_present("108.80")
    assert @selenium.is_text_present("154.10")

    ## orders are ordered with newest on top - index 0 thus yields order2
    @selenium.click "name=commit_time index=0"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Archiv - Bestellung", @selenium.get_title
    assert @selenium.is_text_present("Product 2")
    assert @selenium.is_text_present("Product 3")
    assert @selenium.is_text_present("Total Sfr. 154.10")
    assert !@selenium.is_text_present("Interne Bestellnummer")
    assert !@selenium.is_text_present("Bemerkungen")
    assert !@selenium.is_text_present("Versandart")

    ## go directly to the next order without returning to orders
    @selenium.open "/de/order/order_id/007-1"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Archiv - Bestellung", @selenium.get_title
    assert @selenium.is_text_present("Product 1")
    assert @selenium.is_text_present("Product 2")
    assert @selenium.is_text_present("Total Sfr. 108.80")
    assert @selenium.is_text_present("Interne Bestellnummer")
    assert @selenium.is_text_present("Réf. N°")
    assert @selenium.is_text_present("Bemerkungen")
    assert @selenium.is_text_present("Freetext")
    assert @selenium.is_text_present("Versandart")
    assert @selenium.is_text_present("Terminfracht")
  end
  def test_archive__customer
    customer = setup_customer
    user = login_customer customer
    @selenium.click "link=Archiv"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Archiv", @selenium.get_title
    assert @selenium.is_text_present(Date.today.strftime('%d.%m.%Y'))
    assert @selenium.is_text_present("108.80")
    assert @selenium.is_text_present("154.10")

    ## orders are ordered with newest on top - index 1 thus yields order1
    @selenium.click "name=commit_time index=1"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Archiv - Bestellung", @selenium.get_title
    assert @selenium.is_text_present("Product 1")
    assert @selenium.is_text_present("Product 2")
    assert @selenium.is_text_present("Total Sfr. 108.80")
    assert @selenium.is_text_present("Interne Bestellnummer")
    assert @selenium.is_text_present("Réf. N°")
    assert @selenium.is_text_present("Bemerkungen")
    assert @selenium.is_text_present("Freetext")
    assert @selenium.is_text_present("Versandart")
    assert @selenium.is_text_present("Terminfracht")
  end
end
  end
end
