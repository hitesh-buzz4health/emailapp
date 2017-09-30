#!/usr/bin/env ruby

require 'capybara'

ENV['RAILS_ENV'] ||= ('development')

session = Capybara::Session.new(:selenium) 
session1 = Capybara::Session.new(:selenium) 


ARGV[1].to_i.times do
	session.visit ARGV[0]
	sleep 1
end