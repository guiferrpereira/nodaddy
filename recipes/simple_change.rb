#!/usr/bin/env ruby

require 'no_daddy'


# AUTOMATIC CONFIGURATIONS
# ==============================================================================
Mongoid::load!( File.dirname(__FILE__) + "/../config/mongoid.yml", :development)

puts "----------------------------------------------------------------"
puts "NoDaddy"
puts "\nRecipe: Simple change nameservers."
puts "----------------------------------------------------------------"

selected_name_servers = %w/FREEDNS1.REGISTRAR-SERVERS.COM FREEDNS2.REGISTRAR-SERVERS.COM FREEDNS3.REGISTRAR-SERVERS.COM FREEDNS4.REGISTRAR-SERVERS.COM/

batch = NoDaddy::Batch.first
executor = NoDaddy::Executor.new(batch)
executor.login(batch.account.username, batch.account.password)

File.open( ARGV.shift ).each do |domain|
  domain.strip!
	puts "Working on #{domain}..."
  domain = NoDaddy::Domain.where(:url => domain.upcase).first

  executor.goto_domain_manager(domain.url)

  new_name_servers = selected_name_servers
  executor.change_nameservers(domain, new_name_servers)

  puts "Done."
end
