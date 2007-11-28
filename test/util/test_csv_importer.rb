#!/usr/bin/env ruby
# Util::TestCsvImporter -- sandoz.bbmb.ch -- 19.11.2007 -- hwyss@ywesee.com

$: << File.expand_path('../../lib', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

require 'test/unit'
require 'stub/persistence'
require 'bbmb/util/csv_importer'
require 'flexmock'

module BBMB
  module Util
class TestCsvImporter < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_import
    src = StringIO.new "\344\366\374"
    importer = flexmock(CsvImporter.new)
    importer.should_receive(:import_record).and_return { |record|
      assert_equal(u("äöü"), record.first)
    }
    importer.import(src)
  end
  def test_string
    importer = CsvImporter.new
    assert_nil(importer.string(''))
  end
end
class TestCustomerImporter < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    Model::Customer.clear_instances
    BBMB.server = flexmock('server')
    BBMB.server.should_ignore_missing
    @dir = File.expand_path('data', File.dirname(__FILE__))
  end
  def test_import
    src = File.open(File.join(@dir, 'Kunden.TXT'))
    persistence = flexmock("persistence")
    persistence.should_receive(:save).times(14).and_return { |customer|
      assert_instance_of(Model::Customer, customer)
    }
    CustomerImporter.new.import(src, persistence)
  end
  def test_import_record
    line = StringIO.new <<-EOS
4100603650	7601001024410	Publikums-Apotheke	Frau	Nxxxx	Sxxxxxxx	Pxxx-Axxxxxxx		Hxxxxxxxxxxx XX	XXXX	Kxxxxxxxxxx	0XX XXX XX 55	0XX XXX XX 50
    EOS
    importer = CustomerImporter.new
    persistence = flexmock("persistence")
    persistence.should_receive(:save).times(1)\
      .and_return { |customer|
      assert_instance_of(Model::Customer, customer)
      assert_equal("4100603650", customer.customer_id)
      assert_equal("7601001024410", customer.ean13)
      assert_equal("Frau", customer.title)
      assert_equal("Nxxxx", customer.firstname)
      assert_equal("Sxxxxxxx", customer.lastname)
      assert_equal("Pxxx-Axxxxxxx", customer.organisation)
      assert_equal("Hxxxxxxxxxxx XX", customer.address1)
      assert_equal("XXXX", customer.plz)
      assert_equal("Kxxxxxxxxxx", customer.city)
      assert_equal("0XX XXX XX 55", customer.phone_business)
      assert_equal("0XX XXX XX 50", customer.fax)
    }
    importer.import(line, persistence)
  end
  def test_import_record__protected
    line = StringIO.new <<-EOS
4100603650	7601001024410	Publikums-Apotheke	Frau	Nxxxx	Sxxxxxxx	Pxxx-Axxxxxxx		Hxxxxxxxxxxx XX	XXXX	Kxxxxxxxxxx	0XX XXX XX 55	0XX XXX XX 50
    EOS
    customer = Model::Customer.new("4100603650")
    customer.address1 = 'corrected line'
    customer.protect!(:address1)
    importer = CustomerImporter.new
    persistence = flexmock("persistence")
    persistence.should_receive(:save).times(1)\
      .and_return { |customer|
      assert_instance_of(Model::Customer, customer)
      assert_equal("4100603650", customer.customer_id)
      assert_equal("7601001024410", customer.ean13)
      assert_equal("Frau", customer.title)
      assert_equal("Nxxxx", customer.firstname)
      assert_equal("Sxxxxxxx", customer.lastname)
      assert_equal("Pxxx-Axxxxxxx", customer.organisation)
      assert_equal("corrected line", customer.address1)
      assert_equal("XXXX", customer.plz)
      assert_equal("Kxxxxxxxxxx", customer.city)
      assert_equal("0XX XXX XX 55", customer.phone_business)
      assert_equal("0XX XXX XX 50", customer.fax)
    }
    importer.import(line, persistence)
  end
end
class TestProductImporter < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    Model::Product.clear_instances
    @dir = File.expand_path('data', File.dirname(__FILE__))
  end
  def test_import
    src = File.open(File.join(@dir, 'Artikel.TXT'))
    persistence = flexmock("persistence")
    persistence.should_receive(:save).times(50).with(Model::Product)
    persistence.should_receive(:all)
    ProductImporter.new.import(src, persistence)
  end
  def test_import_record
    existing = Model::Product.new("00510680")
    line = StringIO.new <<-EOS
00546829	BILOL 5 mg Filmtbl 30	BILOL 5MG 30FCT CH	7680540300100	2324008	       8.29
    EOS
    persistence = flexmock("persistence")
    persistence.should_receive(:save).and_return { |product|
      assert_instance_of(Model::Product, product)
      assert_equal("00546829", product.article_number)
      assert_equal("BILOL 5 mg Filmtbl 30", product.description.de)
      assert_equal("BILOL 5MG 30FCT CH", product.description.fr)
      assert_equal(8.29, product.price)
      assert_equal("7680540300100", product.ean13)
      assert_equal("2324008", product.pcode)
    }
    persistence.should_receive(:all).and_return { |klass, block|
      case klass.name
      when "BBMB::Model::Product"
        block.call(existing)
      when "BBMB::Model::Customer"
        block.call(klass.new('test'))
      end
    }
    persistence.should_receive(:delete).with(existing)
    ProductImporter.new.import(line, persistence)
  end
end
  end
end
