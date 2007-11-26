#!/usr/bin/env ruby
# Selenium::TestLogin -- bbmb.ch -- 21.09.2006 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))

require "selenium/unit"

module BBMB
  module Selenium
class TestLogin < Test::Unit::TestCase
  include Selenium::TestCase
  def test_login
    open "/"
    assert_equal "BBMB", get_title
    assert is_text_present("Wilkommen bei Sandoz")
    assert_equal "Email", get_text("//label[@for='email']")
    assert is_element_present("email")
    assert_equal "Passwort", get_text("//label[@for='pass']")
    assert is_element_present("pass")
    assert_match Regexp.new(BBMB.config.http_server), 
      get_attribute("//form[@name='login']@action")
    assert is_element_present("//input[@name='login']")
  end
  def test_login__fail_unknown_user
    open "/"
    assert_equal "BBMB", get_title
    @auth.should_receive(:login).and_return { raise Yus::UnknownEntityError }
    type "email", "unknown@bbmb.ch"
    type "pass", "secret"
    click "//input[@type='submit']"
    wait_for_page_to_load "30000"
    assert_equal "BBMB", get_title
    assert_equal "error", get_attribute("//label[@for='email']@class")
  end
  def test_login__fail_wrong_password
    open "/"
    assert_equal "BBMB", get_title
    @auth.should_receive(:login).and_return { raise Yus::AuthenticationError }
    type "email", "unknown@bbmb.ch"
    type "pass", "secret"
    click "//input[@type='submit']"
    wait_for_page_to_load "30000"
    assert_equal "BBMB", get_title
    assert_equal "error", get_attribute("//label[@for='pass']@class")
  end
  def test_login__force_home
    open "/"
    assert_equal "BBMB", get_title
    open "/de/home"
    assert is_text_present("Wilkommen bei Sandoz")
    assert is_element_present("email")
    assert is_element_present("pass")
    assert is_element_present("//input[@name='login']")
  end
  def test_logout__clean
    @auth.should_ignore_missing
    @persistence.should_receive(:all).and_return([])
    user = login_admin
    assert is_element_present("link=Abmelden")
    assert_equal "Abmelden", get_text("link=Abmelden")
    click "link=Abmelden"
    wait_for_page_to_load "30000"
    assert_equal "BBMB", get_title
    assert_equal "Email", get_text("//label[@for='email']")
    assert is_element_present("email")
    assert_equal "Passwort", get_text("//label[@for='pass']")
    assert is_element_present("pass")
    open "/de/customers"
    # session is now invalid, we stay in login-mask
    assert_equal "BBMB", get_title
    assert_equal "Email", get_text("//label[@for='email']")
    assert is_element_present("email")
    assert_equal "Passwort", get_text("//label[@for='pass']")
    assert is_element_present("pass")
  end
  def test_logout__timeout
    @auth.should_ignore_missing
    @persistence.should_receive(:all).and_return([])
    user = login_admin
    user.should_receive(:expired?).and_return(true)
    user.should_receive(:logout)
    refresh
    wait_for_page_to_load "30000"
    assert_equal "BBMB", get_title
    assert is_element_present("email")
    assert is_element_present("pass")
  end
  def test_logout__disconnect
    @auth.should_ignore_missing
    @persistence.should_receive(:all).and_return([])
    user = login_admin
    user.should_receive(:expired?).and_return { raise DRb::DRbError }
    refresh
    wait_for_page_to_load "30000"
    assert_equal "BBMB", get_title
    assert is_element_present("email")
    assert is_element_present("pass")
  end
  def test_new_customer_form
    open "/"
    assert_equal "BBMB", get_title
    assert_equal "Neuer Kunde", get_text("//label[@for='new_customer']")
    assert_equal <<-EOS.strip,  get_text("//a[@name='new_customer']")
Bestellen Sie jetzt online. Wir richten für Sie den spezifisch auf Ihre Praxis zugeschnittenen, benutzerfreundlichen E-Shop ein!
Unser Kundenservice oder unsere Aussendienstmitarbeiter beraten Sie gerne!
    EOS
    assert_match Regexp.new("^mailto:"), 
                 get_attribute("//a[@name='new_customer']@href")
  end
end
  end
end
