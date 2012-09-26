#!/usr/bin/env ruby
require 'no_daddy'

file_name = File.dirname(__FILE__) + "/../config/godaddy_accounts.yml"

godaddy = YAML::load( File.open( file_name ))
accounts = godaddy[:accounts]

accounts.each do |account|

	# start session
	session = NoDaddy::Session.new
	
	# retrieve create batch
	batch = session.batch

	# create and relate account
	batch_acc = NoDaddy::Account.new
	batch_acc.username = account[:username]
	batch_acc.password = account[:password]
	batch.account = batch_acc
	batch.save!
	
	# create executor
	executor = NoDaddy::Executor.new(batch)

	# login into godaddy
	executor.login(batch.account.username, batch.account.password)

	puts ""
	puts "logging: batch " + batch.number.to_s + " - " + batch.account.username

	# log domains
	executor.goto_domains_list
	executor.log_domains
	
	# make batch ready to process
	batch.ready = true
	batch.save!

	puts "logging: batch " + batch.number.to_s + " - " + batch.account.username + " -- finished"	
end



