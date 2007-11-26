#!/usr/bin/env ruby
# Selenium::TestFavorites -- bbmb.ch -- 05.10.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require "selenium/unit"

module BBMB
  module Selenium
class TestFavorites < Test::Unit::TestCase
  include Selenium::TestCase
  def test_favorites
    user = login_customer
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 0 Positionen")
    assert @selenium.is_element_present("//table[@id='favorites']")
    assert @selenium.is_element_present("file_chooser")
    assert @selenium.is_element_present("favorite_transfer")
    assert_equal "Datei zu Schnellb.", @selenium.get_value("favorite_transfer")
    assert @selenium.is_element_present("query")
    assert @selenium.is_element_present("search_favorites")
    assert_equal "Suchen", @selenium.get_value("search_favorites")
    assert !@selenium.is_element_present("clear_favorites")
    assert !@selenium.is_element_present("increment_order")
    assert !@selenium.is_element_present("nullify")
    assert !@selenium.is_element_present("default_values")
  end
  def test_favorites__with_position
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
    customer.favorites.add(15, product)
    user = login_customer(customer)
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 1 Positionen")
    assert !@selenium.is_text_present("im Rückstand")
    assert @selenium.is_element_present("file_chooser")
    assert @selenium.is_element_present("favorite_transfer")
    assert @selenium.is_element_present("clear_favorites")
    assert_equal "Schnellb. löschen", @selenium.get_value("clear_favorites")
    assert @selenium.is_text_present("2 Stk. à 12.50")
    assert @selenium.is_text_present("3 Stk. à 13.50")
    assert @selenium.is_element_present("increment_order")
    assert_equal "Zu Best. hinzufügen", @selenium.get_value("increment_order")
    assert @selenium.is_element_present("nullify")
    assert_equal "Alles auf 0 setzen", @selenium.get_value("nullify")
    assert @selenium.is_element_present("default_values")
    assert_equal "Voreinstellungen", @selenium.get_value("default_values")
    assert @selenium.is_element_present("quantity[12345]")
    assert_equal "15", @selenium.get_value("quantity[12345]")
    @selenium.click("nullify")
    assert_equal "0", @selenium.get_value("quantity[12345]")
    @selenium.click("default_values")
    assert_equal "15", @selenium.get_value("quantity[12345]")

=begin # works, but throws an error when run with other tests, reason unclear
    @selenium.choose_cancel_on_next_confirmation
    @selenium.click("clear_favorites")
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 1 Positionen")
    assert_equal "Wollen Sie wirklich die gesamte Schnellbestellung löschen?",
                 @selenium.get_confirmation
    @selenium.click("clear_favorites")
=end
    @selenium.open('/de/clear_favorites') # <- workaround
    @selenium.wait_for_page_to_load "30000"
    @selenium.choose_cancel_on_next_confirmation
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 0 Positionen")
  end
  def test_favorites__transfer_dat
    datadir = File.expand_path('data', File.dirname(__FILE__))
    BBMB.persistence.should_ignore_missing
    user = login_customer
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 0 Positionen")
    assert @selenium.is_element_present("file_chooser")
    assert @selenium.is_element_present("favorite_transfer")

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
    @selenium.click "favorite_transfer"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title

    assert @selenium.is_text_present("Aktuelle Schnellbest.: 2 Positionen"), 
           "Most likely firefox is blocking Javascript-Fileupload."
    assert @selenium.is_text_present("product - by pcode")
    assert @selenium.is_text_present("product - by ean13")
    assert @selenium.is_text_present("Unidentifiziertes Produkt (Tramal gtt 10 ml 100 mg/ml, EAN-Code: 7680437880197, Pharmacode: 933022)")

    @selenium.click "name=delete index=2"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert !@selenium.is_text_present("Unidentifiziertes Produkt (Tramal gtt 10 ml 100 mg/ml, EAN-Code: 7680437880197, Pharmacode: 933022)")
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 2 Positionen")

    @selenium.click "name=delete index=1"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 1 Positionen")
    assert @selenium.is_text_present("product - by ean13")
    assert !@selenium.is_text_present("product - by pcode")
  ensure
    FileUtils.rm_r(datadir) if(File.exist?(datadir))
  end
  def test_favorites__increment_order
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
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
    favs = customer.favorites
    favs.add(5, product2)
    favs.add(7, product3)
    user = login_customer customer
    assert_equal "BBMB | Home", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Bestellung: 2 Positionen")

    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 2 Positionen")
    @selenium.type "quantity[3]", "trigger an error"
    @selenium.click "increment_order"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 2 Positionen")
    @selenium.type "quantity[3]", "11"
    @selenium.click "increment_order"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("Aktuelle Bestellung: 3 Positionen")
    assert @selenium.is_text_present("Total Sfr. 266.10")
    assert_equal [['1', 2], ['2', 8], ['3', 11]], order.collect { |position|
      [position.article_number, position.quantity]
    }
    assert_equal [['2', 5], ['3', 7]], favs.collect { |position|
      [position.article_number, position.quantity]
    }
  end
  def test_favorites__scan
    BBMB.persistence.should_ignore_missing
    user = login_customer
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 0 Positionen")

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

    @selenium.open('/de/favorites')
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title

    assert @selenium.is_text_present("Aktuelle Schnellbest.: 1 Positionen")
    assert @selenium.is_text_present("product 1")
    assert @selenium.is_text_present("Unidentifiziertes Produkt (EAN-Code: 7680123456781)")
  end
  def test_favorites__backorder
    BBMB.persistence.should_ignore_missing
    product = Model::Product.new('12345')
    product.description.de = 'product - a description'
    product.price = Util::Money.new(11.50)
    product.l1_price = Util::Money.new(12.50)
    product.l1_qty = 2
    product.l2_price = Util::Money.new(13.50)
    product.l2_qty = 3
    product.backorder = true
    email = 'test.customer@bbmb.ch'
    customer = Model::Customer.new('007')
    customer.instance_variable_set('@email', email)
    customer.favorites.add(15, product)
    user = login_customer(customer)
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 1 Positionen")
    assert @selenium.is_text_present("im Rückstand")
  end
  def test_favorites__barcode_controls
    session = flexstub(@server['test:preset-session-id'])
    session.should_receive(:client_activex?).and_return(true)
    BBMB.persistence.should_ignore_missing
    user = login_customer
    @selenium.click "link=Schnellbestellung"
    @selenium.wait_for_page_to_load "30000"
    assert_equal "BBMB | Schnellbestellung", @selenium.get_title
    assert @selenium.is_text_present("Aktuelle Schnellbest.: 0 Positionen")
    assert @selenium.is_element_present("//a[@name='barcode_usb']")
    assert @selenium.is_element_present("//input[@name='barcode_button']")
    assert @selenium.is_element_present("//input[@name='barcode_comport']")
  end
end
  end
end
