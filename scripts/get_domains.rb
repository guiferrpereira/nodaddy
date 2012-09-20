#! /bin/ruby
require 'no_daddy'

session = NoDaddy::Session.new

godaddy = YAML::load( File.open( '../config/godaddy_accounts.yml' ))
accounts = godaddy[:accounts]

accounts.each do |account|
	
	executor = NoDaddy::Executor.new(session.batch)
	executor.login(account[:username], account[:password])

	executor.goto_domains_list
	executor.log_domains
end



