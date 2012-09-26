#! /bin/ruby

require 'no_daddy'


# AUTOMATIC CONFIGURATIONS
# ==============================================================================
Mongoid::load!( File.dirname(__FILE__) + "/../config/mongoid.yml", :development)
ready_batches = NoDaddy::Batch.all_of( {:ready => true, :finished.in => [nil, false]} )
abort('No batches ready to process ... exiting') if ready_batches.count < 1


puts "----------------------------------------------------------------"
puts "NoDaddy"
puts "\nRecipe: Unlock Domains."
puts "----------------------------------------------------------------"


# ------------------------------------------------------------------------------
puts "\nBatches ready to process"
# ------------------------------------------------------------------------------
ready_batches.each do |batch|
	puts batch.number.to_s + ": " + batch.account.username + " -- domains = " + batch.domains.count.to_s
end


# ------------------------------------------------------------------------------
puts "\nSelect batch(es) to process"
puts "> hit enter for most recent batch, #{ready_batches.last.number}"
puts "> or 1,2,3 to process batch 1, batch 2, batch 3"
# ------------------------------------------------------------------------------
user_requested_batches = gets


# ------------------------------------------------------------------------------
# selecting batches
# ------------------------------------------------------------------------------
if user_requested_batches == "\n"
	batches = [ready_batches.last] 
else
	# turn, "1, 2, 3", into, [1,2,3]
	batch_numbers = user_requested_batches.split(",").map {|n| n.to_i}	
	batches = NoDaddy::Batch.where(:number.in => batch_numbers)
end


# ------------------------------------------------------------------------------
puts "\nSelected ..."
# ------------------------------------------------------------------------------
batches.each do |batch|
	# puts batch.account.username
	puts batch.number.to_s + ": " + batch.account.username + " -- domains = " + batch.domains.count.to_s
end


# ------------------------------------------------------------------------------
puts "\nUnlock ... "
puts ">0: domains ALL"
puts ">1: domains expiring this WEEK"
puts ">2: domains expiring this MONTH"
puts ">3: domains expiring this YEAR"
# ------------------------------------------------------------------------------
user_select_timeframe = gets.to_i

case user_select_timeframe
	when 0 then time_frame = Time.now + (60 * 60 * 24 * 365 * 10)
	when 1 then time_frame = Time.now + (60 * 60 * 24 * 7)
	when 2 then time_frame = Time.now + (60 * 60 * 24 * 30)
	when 3 then time_frame = Time.now + (60 * 60 * 24 * 365)
	else 
		abort("Need to select which group of domains to unlock ... exiting")
	end												


# ------------------------------------------------------------------------------
puts "\nSeleced all domains expiring between now and:"
puts "#{time_frame}"
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
puts "\nProceed? (y)"
# ------------------------------------------------------------------------------
proceed = gets.strip
abort("\nResponded with something other than 'y' ... exiting") unless proceed.eql?("y") || proceed.eql?("Y")
puts ""

puts "\n\n=======>>>>>> batch operation start"


# batches.each do |batch|

# 	puts "unlocking domains in batch: " + batch.number.to_s

# 	# come up with other marking system
# 	# # mark batch as stared
# 	# # batch.started = true
# 	# # batch.save!

# 	# create executor
# 	executor = NoDaddy::Executor.new(batch)
# 	executor.login(batch.account.username, batch.account.password)

# 	batch.domains.each_with_index do |domain, index|
# 		print "#{index} of #{batch.domains.count}" + "\r"
		
# 		executor.goto_domains_list
# 		executor.goto_domain_manager(domain.url)

# 		# load domains settings
# 		if choice == 1
# 			puts "domain.url = " + domain.url
# 			ds = NoDaddy::DomainSetting.where(url: domain.url).first

# 			# only change nameservers for domains with a domain setting
# 			unless ds.nil?
# 				new_name_servers = ds.nameservers
# 				executor.change_nameservers(domain, new_name_servers)
# 			end
		
# 		# load the global nameserver configs 
# 		else
# 			new_name_servers = selected_name_servers
# 			executor.change_nameservers(domain, new_name_servers)
# 		end
# 	end

# 	batch.finished = true
# 	batch.save!
	
# 	puts "changing nameservers for: batch " + batch.number.to_s + " -- finished"
# end
