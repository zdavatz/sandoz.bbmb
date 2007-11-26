#!/usr/bin/env ruby
# Selenium::TestCurrentOrder -- bbmb.ch -- 22.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'selenium/unit'

module BBMB
  module Selenium
class TestCurrentOrder < Test::Unit::TestCase
  include Selenium::TestCase
  def test_current_order__empty
    user = login_customer
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 0 Positionen")
    assert @selenium.is_text_present("Sie sind angemeldet als test.customer@bbmb.ch")
    assert @selenium.is_element_present("file_chooser")
    assert @selenium.is_element_present("order_transfer")
    assert_equal "Datei zu Best.", @selenium.get_value("order_transfer")
    assert @selenium.is_element_present("query")
    assert @selenium.is_element_present("document.search.search")
    assert_equal "Suchen", @selenium.get_value("document.search.search")
  end
  def test_current_order__with_position
    BBMB.persistence.should_ignore_missing
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(11.50)
    product.l1_price = Util::Money.new(12.50)
    product.l1_qty = 2
    product.l2_price = Util::Money.new(13.50)
    product.l2_qty = 3
    email = 'test.customer@bbmb.ch'
    customer = Model::Customer.new('007')
    customer.instance_variable_set('@email', email)
    customer.current_order.add(15, product)
    user = login_customer(customer)
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 1 Positionen")
    assert @selenium.is_text_present("Sie sind angemeldet als test.customer@bbmb.ch")
    assert @selenium.is_element_present("file_chooser")
    assert @selenium.is_element_present("order_transfer")
    assert_equal "Datei zu Best.", @selenium.get_value("order_transfer")
    assert @selenium.is_element_present("clear_order")
    assert_equal "Bestellung löschen", @selenium.get_value("clear_order")
    assert @selenium.is_text_present("2 Stk. à 12.50")
    assert @selenium.is_text_present("3 Stk. à 13.50")
    assert @selenium.is_element_present("reference")
    assert @selenium.is_element_present("comment")
    assert @selenium.is_element_present("document.forms[3].priority")
    assert @selenium.is_element_present("commit")
    assert_equal "Bestellung auslösen", @selenium.get_value("commit")
    assert @selenium.is_text_present("Total Sfr.")
    assert @selenium.is_element_present("total")
    assert_equal "202.50", @selenium.get_text("total")
    @selenium.click "document.forms[3].priority[6]"
    sleep 0.5
    assert_equal "252.50", @selenium.get_text("total")
    @selenium.click "document.forms[3].priority[5]"
    sleep 0.5
    assert_equal "282.50", @selenium.get_text("total")
    @selenium.refresh
    @selenium.wait_for_page_to_load "30000"
    assert_equal "on", @selenium.get_value("document.forms[3].priority[5]")
    @selenium.click "document.forms[3].priority[4]"
    sleep 0.5
    assert_equal "202.50", @selenium.get_text("total")
    @selenium.click "document.forms[3].priority[3]"
    sleep 0.5
    assert_equal "202.50", @selenium.get_text("total")
    @selenium.click "document.forms[3].priority[2]"
    sleep 0.5
    assert_equal "202.50", @selenium.get_text("total")
    @selenium.click "document.forms[3].priority[1]"
    sleep 0.5
    assert_equal "202.50", @selenium.get_text("total")
=begin # works, but throws an error when run with other tests, reason unclear
    @selenium.choose_cancel_on_next_confirmation
    @selenium.click("clear_order")
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 1 Positionen")
    assert_equal "Wollen Sie wirklich die gesamte Bestellung löschen?",
                 @selenium.get_confirmation
    @selenium.click("clear_order")
=end
    @selenium.open('/de/clear_order') # <- workaround
    @selenium.wait_for_page_to_load "30000"
    @selenium.choose_cancel_on_next_confirmation
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 0 Positionen")
  end
  def test_current_order__commit
    BBMB.persistence.should_ignore_missing
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(11.50)
    product.l1_price = Util::Money.new(12.50)
    product.l1_qty = 2
    product.l2_price = Util::Money.new(13.50)
    product.l2_qty = 3
    email = 'test.customer@bbmb.ch'
    customer = Model::Customer.new('007')
    customer.instance_variable_set('@email', email)
    current = customer.current_order
    current.add(15, product)
    user = login_customer(customer)
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 1 Positionen")
    assert @selenium.is_text_present("Sie sind angemeldet als test.customer@bbmb.ch")
    assert @selenium.is_element_present("commit")
    assert_equal "Bestellung auslösen", @selenium.get_value("commit")
    flexstub(BBMB::Util::Mail).should_receive(:send_order).and_return { |order|
      assert_equal(current, order)
      assert_equal(1, order.commit_id)
      assert_not_nil(order.commit_time)
    }
    @selenium.click "commit"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Ihre Bestellung wurde an die Sandoz AG versandt.")
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 0 Positionen")
    @selenium.click "link=Archiv"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Archiv", @selenium.get_title
    assert @selenium.is_text_present(Date.today.strftime('%d.%m.%Y'))
    assert @selenium.is_text_present("202.50")
  end
  def test_current_order__commit__error
    BBMB.persistence.should_ignore_missing
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(11.50)
    product.l1_price = Util::Money.new(12.50)
    product.l1_qty = 2
    product.l2_price = Util::Money.new(13.50)
    product.l2_qty = 3
    email = 'test.customer@bbmb.ch'
    customer = Model::Customer.new('007')
    customer.instance_variable_set('@email', email)
    current = customer.current_order
    current.add(15, product)
    user = login_customer(customer)
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 1 Positionen")
    assert @selenium.is_text_present("Sie sind angemeldet als test.customer@bbmb.ch")
    assert @selenium.is_element_present("commit")
    assert_equal "Bestellung auslösen", @selenium.get_value("commit")
    mail = flexstub(BBMB::Util::Mail)
    mail.should_receive(:send_order).and_return { |order|
      raise "some error"
    }
    mail.should_receive(:notify_error).with(RuntimeError).times(1)
    @selenium.click "commit"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Beim Versand Ihrer Bestellung ist ein Problem aufgetreten.\nEin Administrator wurde automatisch darüber informiert und wird mit Ihnen Kontakt aufnehmen.")
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 0 Positionen")
    @selenium.click "link=Archiv"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Archiv", @selenium.get_title
    assert @selenium.is_text_present(Date.today.strftime('%d.%m.%Y'))
    assert @selenium.is_text_present("202.50")
  end
  def test_current_order__transfer_dat
    datadir = File.expand_path('data', File.dirname(__FILE__))
    BBMB.persistence.should_ignore_missing
    user = login_customer
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 0 Positionen")
    assert @selenium.is_element_present("file_chooser")
    assert @selenium.is_element_present("order_transfer")

    src = <<-EOS
030201899    0624427Mycolog creme tube 15 g                           000176803710902940030201899    1590386Risperdal cpr 20 1 mg                             000176805231601410030201899    0933022Tramal gtt 10 ml 100 mg/ml                        000276804378801970
    EOS
    path = File.join(datadir, 'Transfer.dat')
    FileUtils.mkdir_p(datadir)
    File.open(path, 'w') { |fh| fh.puts src }

    prod1 = Model::Product.new('1')
    prod1.description.de = 'product - by pcode'
    prod1.price = Util::Money.new(11.50)
    prod2 = Model::Product.new('2')
    prod2.description.de = 'product - by ean13'
    prod2.price = Util::Money.new(21.50)

    prodclass = flexstub(Model::Product)
    prodclass.should_receive(:find_by_pcode).and_return { |pcode|
      if(pcode == '624427')
         prod1
      end
    }
    prodclass.should_receive(:find_by_ean13).and_return { |ean13|
      if(ean13 == '7680523160141')
         prod2
      end
    }

    @selenium.type "file_chooser", path
    @selenium.click "order_transfer"
    @selenium.wait_for_page_to_load "30000"

    assert @selenium.is_text_present("Aktuelle Bestellung: 2 Positionen"), 
           "Most likely firefox is blocking Javascript-Fileupload."
    assert @selenium.is_text_present("product - by pcode")
    assert @selenium.is_text_present("product - by ean13")
    assert @selenium.is_text_present("Unidentifiziertes Produkt (Tramal gtt 10 ml 100 mg/ml, EAN-Code: 7680437880197, Pharmacode: 933022)")
    assert @selenium.is_text_present("Total Sfr. 33.00")

    @selenium.click "name=delete index=2"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert !@selenium.is_text_present("Unidentifiziertes Produkt (Tramal gtt 10 ml 100 mg/ml, EAN-Code: 7680437880197, Pharmacode: 933022)")
    assert @selenium.is_text_present("Aktuelle Bestellung: 2 Positionen")

    @selenium.click "name=delete index=1"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 1 Positionen")
    assert @selenium.is_text_present("product - by ean13")
    assert !@selenium.is_text_present("product - by pcode")
  ensure
    FileUtils.rm_r(datadir) if(File.exist?(datadir))
  end
  def test_current_order__scan
    BBMB.persistence.should_ignore_missing
    user = login_customer
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 0 Positionen")

    prod1 = Model::Product.new('1')
    prod1.description.de = 'product 1'
    prod1.price = Util::Money.new(11.50)
    prodclass = flexstub(Model::Product)
    prodclass.should_receive(:find_by_ean13).and_return { |ean13|
      if(ean13 == '7680523160141')
         prod1
      end
    }

    ## simulate barcode-reader
    @selenium.open('/de/scan/EAN_13[7680523160141]/1/EAN_13[7680123456781]/1')
    @selenium.wait_for_page_to_load "30000"

    @selenium.open('/de/current_order')
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title

    assert @selenium.is_text_present("Aktuelle Bestellung: 1 Positionen")
    assert @selenium.is_text_present("product 1")
    assert @selenium.is_text_present("Unidentifiziertes Produkt (EAN-Code: 7680123456781)")
    assert @selenium.is_text_present("Total Sfr. 11.50")
  end
  def test_current_order__sort
    BBMB.persistence.should_ignore_missing
    product1 = Model::Product.new('12345')
    product1.description.de = 'product 1'
    product1.price = Util::Money.new(11.50)
    product1.l1_price = Util::Money.new(12.50)
    product1.l1_qty = 2
    product1.l2_price = Util::Money.new(13.50)
    product1.l2_qty = 3
    product2 = Model::Product.new('23456')
    product2.description.de = 'product 2'
    product2.price = Util::Money.new(2.50)
    product2.l1_price = Util::Money.new(1.50)
    product2.l1_qty = 2
    email = 'test.customer@bbmb.ch'
    customer = Model::Customer.new('007')
    customer.instance_variable_set('@email', email)
    customer.current_order.add(15, product1)
    customer.current_order.add(100, product2)
    user = login_customer(customer)
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 2 Positionen")
    assert_equal "product 1", @selenium.get_text("//tr[2]/td[3]/a") 
    assert_equal "product 2", @selenium.get_text("//tr[4]/td[3]/a") 
    @selenium.click "link=Preis"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 2 Positionen")
    assert_equal "product 2", @selenium.get_text("//tr[2]/td[3]/a") 
    assert_equal "product 1", @selenium.get_text("//tr[4]/td[3]/a") 
    @selenium.click "link=Preis"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 2 Positionen")
    assert_equal "product 1", @selenium.get_text("//tr[2]/td[3]/a") 
    assert_equal "product 2", @selenium.get_text("//tr[4]/td[3]/a") 
  end
  def test_current_order__barcode_controls
    session = flexstub(@server['test:preset-session-id'])
    session.should_receive(:client_activex?).and_return(true)
    BBMB.persistence.should_ignore_missing
    user = login_customer
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 0 Positionen")
    assert @selenium.is_element_present("//a[@name='barcode_usb']")
    assert @selenium.is_element_present("//input[@name='barcode_button']")
    assert @selenium.is_element_present("//input[@name='barcode_comport']")
  end
  def test_current_order__backorder
    BBMB.persistence.should_ignore_missing
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.backorder = true
    product.price = Util::Money.new(11.50)
    product.l1_price = Util::Money.new(12.50)
    product.l1_qty = 2
    product.l2_price = Util::Money.new(13.50)
    product.l2_qty = 3
    email = 'test.customer@bbmb.ch'
    customer = Model::Customer.new('007')
    customer.instance_variable_set('@email', email)
    customer.current_order.add(15, product)
    user = login_customer(customer)
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("im Rückstand")
  end
end
  end
end
