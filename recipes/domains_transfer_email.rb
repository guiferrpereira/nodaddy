#! /bin/ruby/env

require 'no_daddy'


# AUTOMATIC CONFIGURATIONS 
# ==============================================================================
Mongoid::load!( File.dirname(__FILE__) + "/../config/mongoid.yml", :development)
ready_batches = NoDaddy::Batch.all_of( {:ready => true, :finished.in => [nil, false]} )
abort('No batches ready to process ... exiting') if ready_batches.count < 1


puts "--------------------------------------------------------------------"
puts "NoDaddy"
puts "\nRecipe: Domains Transfer Email"
puts "        Get authorization code from email."
puts "--------------------------------------------------------------------"


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
puts "\nProceed? (y)"
# ------------------------------------------------------------------------------
proceed = gets.strip
abort("\nResponded with something other than 'y' ... exiting") unless proceed.eql?("y") || proceed.eql?("Y")
puts ""


batches.each do |batch|

	puts "logging into email: " + batch.account.email_username

	# come up with other marking system
	# # mark batch as stared
	# # batch.started = true
	# # batch.save!

	# # create executor
	# executor = NoDaddy::Executor.new(batch)
	# executor.login(batch.account.username, batch.account.password)

	# # get selected domains
	# time1 = Time.now
	# time2 = time_frame
	# selected_domains = batch.domains_expiring_between(time1, time2)

	# selected_domains.each_with_index do |domain, index|
	# 	print "#{index} of #{batch.domains.count}" + "\r"
		
	# 	executor.goto_domains_list
	# 	executor.goto_domain_manager(domain.url)

	# 	executor.unlock(domain)
	# 	executor.send_authorization_code(domain)
	# end

	# batch.finished = true
	# batch.save!
	
	# puts "changing nameservers for: batch " + batch.number.to_s + " -- finished"
end
