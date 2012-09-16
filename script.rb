require 'yaml'
require 'watir-webdriver'
require 'csv'


# log into godaddy
# navigate to domains
# 	get all domains > write to log
# for each domain
# 	get current domain > write to log 
# 	change domain > write to log
#   go to next domain
# done

class GoDaddyAPI

	def initialize
		load_accounts
		config_log
	end

			def load_accounts
				godaddy = YAML::load( File.open( 'secure/godaddy_accounts.yml' ) )
				@accounts = godaddy["accounts"]
			end

			def config_log
				# log_filename = Dir.glob("log.txt").empty? ? "log.txt" : Time.now.strftime("%Y%m%dT%H%M%S%z")
				log_filename = "log.txt"
				@logger = CSV.open(log_filename, "w")
				@logger << ['Domain Name', 'Old Nameserver 1', 'New Nameserver 1', 'Old Nameserver 2', 'New Nameserver 2', 'Old Nameserver 3', 'New Nameserver 3', 'Old Nameserver 3', 'New Nameserver 4']
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
	
	def get_domain_names
		check_browser
		goto_domains

		result = []

		table = @browser.table(id: 'ctl00_cphMain_DomainList_gvDomains')
		table.rows.each do |r|
			
			# loads 2d array = [domain, expiration date, status]
			result << [r.cells[1].text, r.cells[2].text, r.cells[3].text]
		end

		@domains = result
		return result
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

	private

		# CURRENTLY NOT USED
		# gets domain's status summary
		# def domain_status(domain)
		# 	active = nil

		# 	@browser.table(id:'tblDomainInfoDetails').trs.each do |r|
				
		# 		# get table cell contents
		# 		cell = r.tds[0].text

		# 		# get the keys
		# 		key = cell.split(":")[0]
		# 		key = key.strip if key.class == String
				
		# 		# ge the values (some might be nil)
		# 		value = cell.split(":")[1]
		# 		value = value.strip if value.class == String

		# 		# determine if site is active
		# 		active = (value.include?("Active") ? true : false)
				
		# 		# log the results
		# 		@logger << ["#{domain}", "Active", "#{active}"]
		# 	end

		# 	return active
		# end

end




api = GoDaddyAPI.new
api.accounts.each do |account|
	
	api.login(account)
	
	# get 2d array of domains, [domain, expiration date, status]
	domains = api.get_domain_names
	
	puts "== recognized #{domains.size}"

	domains.each_with_index do |d, i|
		percent = "%.0f" % ((i*100.0)/domains.size)
		
		puts ""
		puts "== #{i} of #{domains.size} - #{percent}%"
		
		api.goto_domain_manager(d[0])
		puts "-- managing #{d[0]}"		

		puts "---- status: #{d[2]}"
		
		if d[2].include?("Active")
			puts "---- changing nameservers"
			api.change_nameservers(d[0], account['nameservers_new'])
		end
	end

end
