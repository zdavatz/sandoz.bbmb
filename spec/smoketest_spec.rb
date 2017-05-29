#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    waitForBbmbToBeReady(@browser, BbmbUrl)
  end
  
  before :each do
    @browser.goto BbmbUrl
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    logout
  end

  after :all do
    @browser.close
  end

  describe "admin" do
    before :all do
    end
    before :each do
      @browser.goto BbmbUrl
      logout
      login(AdminUser, AdminPassword)
    end
    after :all do
      logout
    end
    it "admin should edit package info" do
      @browser.goto "#{BbmbUrl}/de/customer/customer_id/4100609297"
      windowSize = @browser.windows.size
      expect(@browser.url).to match BbmbUrl
      text = @browser.text.clone
      binding.pry
      expect(@browser.url).to match BbmbUrl
    end
  end

end
