#! /bin/ruby

# ruby built in tools
require 'yaml'
require 'csv'

# gems
require 'watir-webdriver'


# ------------------------------------------------------------------------------
class GoDaddyAPI

	def initialize(username, password)
		login(username, password)
	end

	def login(u, p)
		@browser = Watir::Browser.new :firefox

		#login to godaddy
		@browser.goto "http://godaddy.com"
		@browser.link(text: "Log In").click
		@browser.text_field(title: "Enter Username").set(u)
		@browser.text_field(title: "Enter Password").set(p)
		@browser.link(id: "pc-loginSubmitBtn").click
	end

	def browser 
		@browser
	end

	def log_domains(file_writer)
		goto_domains

		table = @browser.table(id: 'ctl00_cphMain_DomainList_gvDomains')
		
		output = {domains: []}

		begin
			table.rows.each do |r|
				hash = Hash.new
				hash[:domain] = r.cells[1].text
				hash[:date_expire] = r.cells[2].text
				hash[:status] = r.cells[3].text

				output[:domains].push(hash)
			end
		end

		file_writer << output.to_yaml
	end

	def goto_domains
		# go to domains center
		@browser.goto("https://mya.godaddy.com/products/ControlPanelLaunch/ControlPanelLaunch.aspx?accordionId=1&generic=true")
	end

	def goto_domain_manager(domain)
		goto_domains
		
		@browser.a(text: domain).click
		@browser.input(value: domain).wait_until_present
	end

	def change_nameservers(domain, new_ns)
		hash = { domain: domain, ns_old: [], ns_new: [], change_date: nil, errors: []}

		begin
			@browser.a(id: 'ctl00_cphMain_lnkNameserverUpdate').click
			@browser.frame(id: 'ifrm').wait_until_present(10)
		rescue Exception => e
			msg = "DOMAIN: #{domain} -- " + e.to_s
			hash[:errors].push(msg)
		end
		
		unless hash[:errors].nil?
			begin
				# log old nameservers 
				0.upto(3) do |index|
					old_ns = @browser.frame(id: 'ifrm').input(id: "ctl00_cphAction1_ctl00_txtNameserver#{index + 1}").value
					hash[:ns_old].push(old_ns)
				end
			rescue Exception => e
				msg = "DOMAIN: #{domain} :: old nameservers -- " + e.to_s
				hash[:errors].push(msg)
			end
		end	

		unless hash[:errors].nil?
			begin
				# input values for new nameservers
				new_ns.each_with_index do |new_ns, index|
					@browser.frame(id: 'ifrm').text_field(id: "ctl00_cphAction1_ctl00_txtNameserver#{index + 1}").set(new_ns)
					hash[:ns_new].push(new_ns)
				end
			rescue Exception => e
				meg = "DOMAIN: #{domain} :: new nameservers -- " + e.to_s
				hash[:errors].push(msg)
			end
		end

		unless hash[:errors].nil?
			begin
				# submit new nameserver values
				@browser.frame(id: 'ifrm').a(text: 'OK').click
				@browser.frame(id: 'ifrm').div(id: 'ctl00_cphAction1_ctl01_pnlReadOnly').wait_until_present
				@browser.frame(id: 'ifrm').a(text: 'OK').click
			rescue Exception => e
				msg = "DOMAIN: #{domain} :: submitting namservers -- " + e.to_s
				hash[:errors].push(msg)
			end

			hash[:change_date] = Time.now
		end

		return hash
	end
end

# ------------------------------------------------------------------------------
class Logger
	def self.csv
		log_filename = Dir.glob("log.csv").empty? ? "log.csv" : Time.now.strftime("%Y%m%dT%H%M%S%z") + ".csv"
	
		csv_writer = CSV.open(log_filename, "w")
	end

	def self.yaml(file_name)
		file = Dir.glob(file_name).empty? ? file_name : Time.now.strftime("%Y%m%dT%H%M%S%z") + ".yml"
		File.open(file, "w")
	end
end


# ==============================================================================
#  GoDaddy Script
# ==============================================================================


# Load accounts
# 
godaddy = YAML::load( File.open( 'secure/godaddy_accounts.yml' ) )

# Select account
# (Currently only used with 1 account, but expandable to multipe accounts.)
# 
account = godaddy[:accounts].first


# Log into GoDaddy
# 
api = GoDaddyAPI.new( account[:username], account[:password] )

# Get domains for account
# Save domains to yaml file
# 
@domain_logger = Logger.yaml("domains.yml")
@domain_logger.sync = true
api.log_domains(@domain_logger)

# Close yaml file (in preparation for others to access it)
# 
@domain_logger.close

# Open domains list. Load into variable
# 
domain_list = YAML::load(File.open("domains.yml"))

# Create "operations" and "inactive domains list" loggers
# 
@ops_logger = Logger.yaml("ops_logger.yml")
@ops_logger.sync = true
@inactive_logger = Logger.yaml("domains_inactive.yml")
@inactive_logger.sync = true
@error_logger = Logger.yaml("errors.yml")
@error_logger.sync = true


# Loop through domain list domains. 
# 
domain_list[:domains].each_with_index do |domain, i|

	# Show status in the terminal
	# 
	percent = "%.0f" % ((i*100.0)/domain_list[:domains].size)
	puts "== #{i} of #{domain_list[:domains].size} - #{percent}%"

	# Select acitve domains
	# 
	if domain[:status].include?("Active")
		puts "-- manage " + domain[:domain]
		api.goto_domain_manager(domain[:domain])
		result = api.change_nameservers(domain[:domain],account[:ns_new])
		@ops_logger << result.to_yaml

		@error_logger << result.to_yaml unless result[:errors].nil?

	# Select inactive domains
	# 
	else		
		hash = {domain: domain[:domain], error: 'domain inactive'}
		
		@ops_logger 			<< hash.to_yaml
		@inactive_logger	<< hash.to_yaml
	end
end

# Close loggers
# 
@ops_logger.close
@inactive_logger.close


# Append log files with timestamps
# 
timestamped_domains 	= "domains."          	+ Time.now.strftime("%Y%m%dT%H%M%S%z") + ".yml"
timestamped_inactive 	= "domains_inactive." 	+ Time.now.strftime("%Y%m%dT%H%M%S%z") + ".yml"
timestamped_ops 			= "ops_logger."        	+ Time.now.strftime("%Y%m%dT%H%M%S%z") + ".yml"
timestamped_errors 		= "errors."   					+ Time.now.strftime("%Y%m%dT%H%M%S%z") + ".yml"

FileUtils.mv "domains.yml",						timestamped_domains
FileUtils.mv "domains_inactive.yml",  timestamped_inactive
FileUtils.mv "ops_logger.yml", 				timestamped_ops
FileUtils.mv "errors.yml", 						timestamped_errors