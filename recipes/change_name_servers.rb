require 'no_daddy'


# AUTOMATIC CONFIGURATIONS
# ==============================================================================
Mongoid::load!( File.dirname(__FILE__) + "/../config/mongoid.yml", :development)
ready_batches = NoDaddy::Batch.all_of( {:ready => true, :finished.in => [nil, false]} )
abort('No batches ready to process ... exiting') if ready_batches.count < 1


puts "----------------------------------------------------------------"
puts "NoDaddy"
puts "\nRecipe: Change nameservers."
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
puts "\nSelect name server configurations ... "
puts "> 0 or  	enter: apply name servers for all domains in batch"
puts "> 1: load namer server settings from 'config/settings/domain_settings.csv' "
# ------------------------------------------------------------------------------
choice = gets
if choice.to_i == 1
	loader = NoDaddy::Loader.new
	loader.load_domain_settings
	puts "--  using contents of CSV file"
else
	puts "\nEnter nameservers separated by comas (max of 4)"
	selected_name_servers = gets.split(',').collect(&:strip)
	abort("Did not enter name servers ... exiting") if selected_name_servers.empty?
	puts "-- using these nameservers = " + selected_name_servers.to_s
end


# ------------------------------------------------------------------------------
puts "\nProceed? (y)"
# ------------------------------------------------------------------------------
proceed = gets
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

		# load domains settings
		if choice == 1
			puts "domain.url = " + domain.url

			ds = DomainSetting.where(url: domain.url)
			new_name_servers = ds.name_servers
		
		# load the global nameserver configs 
		else
			new_name_servers = selected_name_servers
		end

		executor.change_nameservers(domain, new_name_servers)
	end

	batch.finished = true
	batch.save!
	
	puts "changing nameservers for: batch " + batch.number.to_s + " -- finished"
end
