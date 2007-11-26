#!/usr/bin/env ruby
# Selenium::TestCustomer -- bbmb.ch -- 04.10.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'selenium/unit'

module BBMB
  module Selenium
class TestCustomer < Test::Unit::TestCase
  include Selenium::TestCase
  def test_customer
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    click "link=Test-Customer"
    wait_for_page_to_load "30000"
    assert_equal "BBMB | Kunde", get_title

    assert_equal "Kunde*", get_text("//label[@for='organisation']")
    assert is_element_present("organisation")
    assert_equal "Test-Customer", get_value("organisation")

    assert_equal "Kundennr*", get_text("//label[@for='customer_id']")
    assert is_element_present("customer_id")
    assert_equal "007", get_value("customer_id")

    assert_equal "EAN-Code", get_text("//label[@for='ean13']")
    assert is_element_present("ean13")

    assert_equal "Umsatz", get_text("//label[@for='turnover']")
    assert is_element_present("link=Sfr. 0.00")
    url = "http://localhost:10080/de/orders/customer_id/007"
    assert_equal url, get_attribute("//a[@name='turnover']@href")

    assert is_element_present("link=Umsatz")
    assert is_text_present("Sfr. 0.00 - Umsatz")
    assert_equal "Anrede", get_text("//label[@for='title']")
    assert is_element_present("title")
    assert_equal "Titel", get_text("//label[@for='drtitle']")
    assert is_element_present("drtitle")
    assert_equal "Name", get_text("//label[@for='lastname']")
    assert is_element_present("lastname")
    assert_equal "Vorname", get_text("//label[@for='firstname']")
    assert is_element_present("firstname")
    assert_equal "Adresse*", get_text("//label[@for='address1']")
    assert is_element_present("address1")
    assert is_element_present("address2")
    assert is_element_present("address3")
    assert_equal "PLZ", get_text("//label[@for='plz']")
    assert is_element_present("plz")
    assert_equal "Ort", get_text("//label[@for='city']")
    assert is_element_present("city")
    assert is_text_present("PLZ/Ort")
    assert_equal "Kanton", get_text("//label[@for='canton']")
    assert is_element_present("canton")

    assert_equal "Email*", get_text("//label[@for='email']")
    assert is_element_present("email")
    assert_equal "test.customer@bbmb.ch", get_value("email")

    assert_equal "Tel. Geschäft", get_text("//label[@for='phone_business']")
    assert is_element_present("phone_business")
    assert_equal "Tel. Privat", get_text("//label[@for='phone_private']")
    assert is_element_present("phone_private")
    assert_equal "Tel. Mobile", get_text("//label[@for='phone_mobile']")
    assert is_element_present("phone_mobile")
    assert_equal "Fax", get_text("//label[@for='fax']")
    assert is_element_present("fax")

    assert is_element_present("change_pass")
    assert is_element_present("generate_pass")
    assert !is_element_present("pass")
    assert !is_element_present("confirm_pass")

    assert is_element_present("save")
    assert_equal "Speichern", get_value("save")
  end
  def test_customer__save_errors
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    click "link=Test-Customer"
    wait_for_page_to_load "30000"

    click "change_pass"
    wait_for_page_to_load "30000"

    assert is_text_present("Das Benutzerprofil wurde nicht gespeichert!")

    type "ean13", "768012345678"
    click "save"
    wait_for_page_to_load "30000"

    assert is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert is_text_present("Das Passwort war leer.")
    assert_equal "error", get_attribute("//label[@for='address1']@class")
    assert_equal "error", get_attribute("//label[@for='pass']@class")
    assert_equal "error", get_attribute("//label[@for='confirm_pass']@class")
    assert_equal "error", get_attribute("//label[@for='ean13']@class")

    type "address1", "Address"
    type "pass", "secret"
    type "confirm_pass", "terces"
    click "save"
    wait_for_page_to_load "30000"

    assert is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert is_text_present("Das Passwort und die Bestätigung waren nicht identisch.")
    assert is_text_present("Der EAN-Code war ungültig.")
  end
  def test_customer__save
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    user.should_receive(:get_preference).and_return('')

    click "link=Test-Customer"
    wait_for_page_to_load "30000"

    click "change_pass"
    wait_for_page_to_load "30000"

    type "ean13", "7680123456781"
    type "address1", "Address"
    type "pass", "secret"
    type "confirm_pass", "secret"

    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)
    user.should_receive(:grant).times(1).and_return { |email, action, item|
      assert_equal('login', action)
      assert_equal('ch.bbmb.Customer', item)
    }
    user.should_receive(:set_password).times(1).and_return { |email, hash|
      assert_equal('test.customer@bbmb.ch', email)
      assert_equal(Digest::MD5.hexdigest('secret'), hash)
      @yus_entities.store(email, entity)
    }

    click "save"
    wait_for_page_to_load "30000"

    assert !is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert is_element_present("change_pass")
    assert is_element_present("generate_pass")
    assert_equal "Passwort ändern", get_value("change_pass")
  end
  def test_customer__duplicate_email
    BBMB.server = flexmock('server')
    BBMB.server.should_receive(:rename_user).and_return { |old, new|
      raise Yus::YusError, 'duplicate email'
    }
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    user.should_receive(:get_preference).and_return('')

    click "link=Test-Customer"
    wait_for_page_to_load "30000"

    click "change_pass"
    wait_for_page_to_load "30000"

    type "email", "test.user@bbmb.ch"
    type "address1", "Address"
    type "pass", "secret"
    type "confirm_pass", "secret"

    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)

    click "save"
    wait_for_page_to_load "30000"

    assert is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert is_text_present("Es gibt bereits ein Benutzerprofil für diese Email-Adresse")
  end
  def test_customer__password_not_set
    BBMB.server = flexmock('server')
    BBMB.server.should_receive(:rename_user)
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.plz = '7777'
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }
    user = login_admin
    user.should_receive(:get_preference).and_return('')
    user.should_receive(:grant)
    user.should_receive(:set_password).and_return { |old, new|
      raise Yus::YusError, 'other error, user not found, privilege problem'
    }

    click "link=Test-Customer"
    wait_for_page_to_load "30000"

    click "change_pass"
    wait_for_page_to_load "30000"

    type "email", "test.user@bbmb.ch"
    type "address1", "Address"
    type "pass", "secret"
    type "confirm_pass", "secret"

    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)

    click "save"
    wait_for_page_to_load "30000"

    assert is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert is_text_present("Das Passwort konnte nicht gespeichert werden")
  end
  def test_customer__generate_pass
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    customer.drtitle = 'Dr. med. vet.'
    customer.firstname = 'firstname'
    customer.lastname = 'lastname'
    customer.plz = '7777'
    customer.city = 'city'
    customer.ean13 = "7680123456781"
    customer.address1 = "Address"
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }

    user = login_admin
    user.should_receive(:get_preference).and_return('')
    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)
    @yus_entities.store(customer.email, entity)

    click "link=Test-Customer"
    wait_for_page_to_load "30000"

    flexstub(Util::PasswordGenerator).should_receive(:generate).and_return 'pass'

    user.should_receive(:set_password).times(1).and_return { |email, hash|
      assert_equal('test.customer@bbmb.ch', email)
      assert_equal(Digest::MD5.hexdigest('pass'), hash)
      @yus_entities.store(email, entity)
    }

    click "generate_pass"
    wait_for_page_to_load "30000"
    wait_for_page_to_load "30000"

=begin # selecting a window opened by onload does not seem to work.
    select_window('password')
    assert_equal "BBMB | Kunde", get_title
    assert is_text_present("Test-Customer")
    assert is_text_present("Dr. med. vet. firstname lastname")
    assert is_text_present("Address")
    assert is_text_present("7777")
    assert is_text_present("pass")
    assert is_text_present("test.customer@bbmb.ch")
    close
=end

    select_window("null")
    assert !is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert is_element_present("change_pass")
    assert(is_element_present("generate_pass") \
           || is_element_present("show_pass"))
  end
  def test_customer__generate_pass__errors
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    BBMB.persistence.should_ignore_missing
    customer = BBMB::Model::Customer.new('007')
    customer.organisation = 'Test-Customer'
    customer.drtitle = 'Dr. med. vet.'
    customer.firstname = 'firstname'
    customer.lastname = 'lastname'
    customer.plz = '7777'
    customer.city = 'city'
    customer.ean13 = "7680123456781"
    customer.address1 = "Address"
    @persistence.should_receive(:all).and_return { |klass|
      assert_equal(BBMB::Model::Customer, klass)
      [customer]
    }

    user = login_admin
    user.should_receive(:get_preference).and_return('')
    entity = flexmock('yus-entity')
    entity.should_receive(:valid?).and_return(true)
    @yus_entities.store(customer.email, entity)

    click "link=Test-Customer"
    wait_for_page_to_load "30000"

    click "generate_pass"
    wait_for_page_to_load "30000"

    assert is_text_present("Das Benutzerprofil wurde nicht gespeichert!")
    assert is_text_present("Bitte speichern Sie zuerst eine gültige Email-Adresse")
    assert is_element_present("change_pass")
    assert(is_element_present("generate_pass") \
           || is_element_present("show_pass"))


    BBMB.server.should_receive(:rename_user).and_return { |old, new|
      raise Yus::YusError, 'duplicate email'
    }

    flexstub(Util::PasswordGenerator).should_receive(:generate).and_return 'pass'
    user.should_receive(:set_password).times(1).and_return { |email, hash|
      raise Yus::YusError
    }

    type 'email', 'test.customer@bbmb.ch'
    customer.instance_variable_set('@email', 'test.customer@bbmb.ch')
    click "generate_pass"
    wait_for_page_to_load "30000"

    assert is_text_present("Das Passwort konnte nicht gespeichert werden")
  end
end
  end
end
