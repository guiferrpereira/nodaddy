#!/usr/bin/env ruby

require 'no_daddy'


# AUTOMATIC CONFIGURATIONS
# ==============================================================================
Mongoid::load!( File.dirname(__FILE__) + "/../config/mongoid.yml", :development)

puts "----------------------------------------------------------------"
puts "NoDaddy"
puts "\nRecipe: Simple change nameservers."
puts "----------------------------------------------------------------"

selected_name_servers = %w/dns1.stabletransit.com dns2.stabletransit.com/

batch = NoDaddy::Batch.first
executor = NoDaddy::Executor.new(batch)
executor.login(batch.account.username, batch.account.password)

index = 0
File.open( ARGV.shift ).each do |domain|
  index += 1
  domain.strip!
	puts "Working on #{domain}..."
  domain = NoDaddy::Domain.where(:url => domain.upcase).first


  executor.goto_domain_manager(domain.url)

  new_name_servers = selected_name_servers
  executor.change_nameservers(domain, new_name_servers)

  puts "Done."
end
