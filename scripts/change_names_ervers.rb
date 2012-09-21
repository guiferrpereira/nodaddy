require 'no_daddy'

Mongoid::load!( File.dirname(__FILE__) + "/../config/mongoid.yml", :development)

ready_batches = NoDaddy::Batch.where(ready: true)

puts "Batches ready to process\n"
puts ready_batches.map(&:number)


ready_batches.each do |batch|

	# mark batch as stared
	batch.started = true
	batch.save!

	puts "sfsdfsdfsdfsdf"

	# create executor
	executor = NoDaddy::Executor.new(batch)
	executor.login(batch.account.username, batch.account.password)

	batch.domains.each do |domain|
		executor.goto_domains_list
		executor.goto_domain_manager(domain.url)

		executor.change_nameservers(domain, ["cody.ns.cloudflare.com", "lola.ns.cloudflare.com"])
	end
end


# 	# log into account

# 	# define loop group criteria (EG, expire between date1 and date2)
# 	# loop through domains
# 	# do action, creating 

# # 

# # Load accounts
# # 
# godaddy = YAML::load( File.open( 'config/godaddy_accounts.yml' ) )

# # Select account
# # (Currently only used with 1 account, but expandable to multipe accounts.)
# # 
# account = godaddy[:accounts].first
# NoDaddy::Account.new



# # Log into GoDaddy
# # 
# api = NoDaddy::Executor.new( account[:username], account[:password] )

# # Get domains for account
# # Save domains to yaml file
# # 
# @domain_logger = NoDaddy::Logging.yaml("log_domains.yml")
# api.log_domains(@domain_logger)
# @domain_logger.close

# # Open domains list. Load into variable
# # 
# domain_list = YAML::load(File.open("log_domains.yml"))

# # Create "operations" and "inactive domains list" loggers
# # 
# @ops_logger 			= NoDaddy::Logging.yaml("log_ops.yml")      and @ops_logger.sync = true
# @inactive_logger 	= NoDaddy::Logging.yaml("log_inactive.yml") and @inactive_logger.sync = true
# @error_logger 		= NoDaddy::Logging.yaml("log_errors.yml")		and @error_logger.sync = true


# # Loop through domain list domains. 
# # 
# subset = domain_list[:domains][0..1]
# subset.each_with_index do |domain, i|

# # domain_list[:domains].each_with_index do |domain, i|
# 	# Show status in the terminal
# 	# 
# 	percent = "%.0f" % ((i*100.0)/domain_list[:domains].size)
# 	puts "== #{i} of #{domain_list[:domains].size} - #{percent}%"
# 	puts "-- " + domain[:domain]

# 	# Select acitve domains
# 	# 
# 	if domain[:status].include?("Active")
# 		puts "---- changing nameservers"
# 		api.goto_domain_manager(domain[:domain])
# 		result = api.change_nameservers(@ops_logger, domain[:domain],account[:ns_new])
		
# 		unless result[:change_date].nil?
# 			@ops_logger << result.to_yaml
# 		else
# 			@error_logger << result.to_yaml # if result[:errors].size > 0
# 		end

# 	# Select inactive domains
# 	# 
# 	else		
# 		puts "-- no edits to #{domain[:domain]}"
		
# 		hash = {domain: domain[:domain], error: 'domain inactive'}
		
# 		@ops_logger 			<< hash.to_yaml
# 		@inactive_logger	<< hash.to_yaml
# 	end
# 	puts ""

# end

# # Close loggers
# # 
# @ops_logger.close
# @inactive_logger.close


# # Append log files with timestamps
# # 
# util = NoDaddy::Logging.new
# util.timestamp_remove("log_domains.yml")
# util.timestamp_remove("log_inactive.yml")
# util.timestamp_remove("log_ops.yml")
# util.timestamp_remove("log_errors.yml")

