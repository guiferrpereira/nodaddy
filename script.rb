require 'yaml'
require 'watir-webdriver'
require 'csv'

class GoDaddyAPI

	def initialize
		load_accounts
	end

	def load_accounts
		godaddy = YAML::load( File.open( 'secure/godaddy_accounts.yml' ) )
		@accounts = godaddy["accounts"]
	end


	def accounts 
		@accounts
	end

	def browser 
		@browser
	end

	def domains 
		@domains
	end
	
	def log_domains(file_writer)
		check_browser
		goto_domains

		table = @browser.table(id: 'ctl00_cphMain_DomainList_gvDomains')
		
		begin
			table.rows.each do |r|
				hash = Hash.new
				hash[:domain] = r.cells[1].text
				hash[:date_expire] = r.cells[2].text
				hash[:status] = r.cells[3].text

				file_writer.write hash.to_yaml
			end
		end
	end

	def check_browser
		puts "@browser is nil" if @browser.nil?
	end

	def login(account)
		@browser = Watir::Browser.new :firefox

		#login to godaddy
		@browser.goto "http://godaddy.com"
		@browser.link(text: "Log In").click
		@browser.text_field(title: "Enter Username").set(account["username"])
		@browser.text_field(title: "Enter Password").set(account["password"])
		@browser.link(id: "pc-loginSubmitBtn").click

		@account = account
	end

	def goto_domains
		check_browser

		# go to domains center
		@browser.goto("https://mya.godaddy.com/products/ControlPanelLaunch/ControlPanelLaunch.aspx?accordionId=1&generic=true")
	end

	def goto_domain_manager(domain)
		check_browser
		goto_domains
		
		@browser.a(text: domain).click
		@browser.input(value: domain).wait_until_present
	end

	def change_nameservers(domain, new_ns)
		check_browser

		@browser.a(id: 'ctl00_cphMain_lnkNameserverUpdate').click
		@browser.frame(id: 'ifrm').wait_until_present(10)

		# log old nameservers 
		1.upto(4) do |index|
			old_ns = @browser.frame(id: 'ifrm').input(id: "ctl00_cphAction1_ctl00_txtNameserver#{index}").value
			@logger << ["#{domain}", "Old NS #{index}: #{old_ns}"]
		end

		# input values for new nameservers
		new_ns.each_with_index do |ns, index|
			index += 1 
			if index > 4
				msg = "Only 4 Nameservers are supported -- exiting script"
				logger << msg
				abort(msg)
			end

			@browser.frame(id: 'ifrm').text_field(id: "ctl00_cphAction1_ctl00_txtNameserver#{index}").set(ns)
			@logger << [domain, "New NS #{index}: #{ns}"]
		end
		
		# submit new nameserver values
		@browser.frame(id: 'ifrm').a(text: 'OK').click
		@browser.frame(id: 'ifrm').div(id: 'ctl00_cphAction1_ctl01_pnlReadOnly').wait_until_present
		@browser.frame(id: 'ifrm').a(text: 'OK').click
	end

end


class Domain
	def self.hash
		{ domain: '', ns_old: [], ns_new: [], status: nil, date_expire: nil, ns_changed_date: nil, errors: nil}
	end
end

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


api = GoDaddyAPI.new

api.accounts.each do |account|
	
	@logger = Logger.yaml("domains.yml")
	@logger.sync = true

	api.login(account)
	api.log_domains(@logger)

	# puts "== recognized #{domains.size}"

	# domains.each_with_index do |d, i|
	# 	percent = "%.0f" % ((i*100.0)/domains.size)
		
	# 	puts ""
	# 	puts "== #{i} of #{domains.size} - #{percent}%"
		
	# 	api.goto_domain_manager(d[0])
	# 	puts "-- managing #{d[0]}"		

	# 	puts "---- status: #{d[2]}"
		
	# 	if d[2].include?("Active")
	# 		puts "---- changing nameservers"
			
	# 		# catch webdriver errors
	# 		begin
	# 			api.change_nameservers(d[0], account['nameservers_new'])
	# 		rescue => e
	# 			# this error has been causing most of the errors
	# 			# Selenium::WebDriver::Error::StaleElementReferenceError

	# 		end

	# 	end
	# end

end
