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


godaddy = YAML::load( File.open( 'secure/godaddy_accounts.yml' ) )
accounts = godaddy["accounts"]

# log_filename = Dir.glob("log.txt").empty? ? "log.txt" : Time.now.strftime("%Y%m%dT%H%M%S%z")
log_filename = "log.txt"
@logger = CSV.open(log_filename, "w")

@browser = Watir::Browser.new :firefox

accounts.each do |account|
	
	#login to godaddy
	@browser.goto "http://godaddy.com"
	@browser.link(text: "Log In").click
	@browser.text_field(title: "Enter Username").set(account["username"])
	@browser.text_field(title: "Enter Password").set(account["password"])
	@browser.link(id: "pc-loginSubmitBtn").click	
	
	# go to domains center
	@browser.goto("https://mya.godaddy.com/products/ControlPanelLaunch/ControlPanelLaunch.aspx?accordionId=1&generic=true")

	# record all domains
	
	# table
	table = @browser.table(id: 'ctl00_cphMain_DomainList_gvDomains')
	@logger << table.strings
end

def list_domains
end

def get_nameservers(domain)
end

def change_nameserver(domain, new_nameservers)
end

def is_changed
end

def browser_location
end