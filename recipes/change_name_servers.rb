require 'no_daddy'


# MANUAL CONFIGURATIONS
# ==============================================================================
# new_name_servers = ["nameserver_1", "nameserver_2"]
new_name_servers = []
abort("\nNeed to specify new name servers ... exiting") unless new_name_servers.size > 0



# AUTOMATIC CONFIGURATIONS
# ==============================================================================
Mongoid::load!( File.dirname(__FILE__) + "/../config/mongoid.yml", :development)
ready_batches = NoDaddy::Batch.all_of( {:ready => true, :finished.in => [nil, false]} )


puts "----------------------------------------------------------------"
puts "NoDaddy"
puts "\nChange nameservers to:\n"
new_name_servers.each {|ns| puts "> " + ns}
puts "----------------------------------------------------------------"




# ------------------------------------------------------------------------------
puts "\nBatches ready to process"
# ------------------------------------------------------------------------------
ready_batches.each do |batch|
	puts batch.number.to_s + ": " + batch.account.username + " -- domains = " + batch.domains.count.to_s
end


# ------------------------------------------------------------------------------
puts "\nSelect batch(es) to process"
puts "> hit enter #{ready_batches.last.number})"
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
puts "\nProceed? (y)"
# ------------------------------------------------------------------------------
proceed = gets


# ------------------------------------------------------------------------------
# about if not y || Y
# ------------------------------------------------------------------------------
abort("\nResponded with something other than 'y' ... exiting") unless proceed.eql?("y\n") || proceed.eql?("Y\n")
puts ""



batches.each do |batch|

	puts "changing nameservers for: batch " + batch.number.to_s

	# mark batch as stared
	batch.started = true
	batch.save!

	# create executor
	executor = NoDaddy::Executor.new(batch)
	executor.login(batch.account.username, batch.account.password)

	batch.domains.each_with_index do |domain, index|
		print "#{index} of #{batch.domains.count}" + "\r"
		
		executor.goto_domains_list
		executor.goto_domain_manager(domain.url)

		executor.change_nameservers(domain, new_name_servers)
	end

	batch.finished = true
	batch.save!
	
	puts "changing nameservers for: batch " + batch.number.to_s + " -- finished"
end
