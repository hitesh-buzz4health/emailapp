#!/usr/bin/env ruby

require 'watir'


Selenium::WebDriver::Firefox::Binary.path = "/home/bliss/Downloads/tor-browser_en-US/Browser/firefox"
#profile = Selenium::WebDriver::Firefox::Profile.new('/home/bliss/Downloads/tor-browser_en-US/Browser/TorBrowser/Data/Browser/profile.default')
#driver = Selenium::WebDriver.for :firefox
#driver.get('https://check.torproject.org/')

browser = Watir::Browser.new :firefox
browser.goto 'https://check.torproject.org/' 