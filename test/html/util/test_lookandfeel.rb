$: << File.dirname(__FILE__)
$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../../lib', File.dirname(__FILE__))

require 'minitest/autorun'
require 'flexmock/minitest'
require 'sbsm/session'
require 'bbmb/html/util/lookandfeel'

module BBMB
  module Html
    class TestApplication
      def unknown_user; end
    end

    module Util
      class TestLookandfeel < ::Minitest::Test
        def setup
          @app     = TestApplication.new
          @session = SBSM::Session.new('test', @app)
        end

        def test_base_url_does_not_include_flavor
          lookandfeel = Lookandfeel.new(@session)
          assert_equal('sbsm', lookandfeel.flavor)
          refute_match(@session.flavor, lookandfeel.base_url)
        end
      end
    end
  end
end
