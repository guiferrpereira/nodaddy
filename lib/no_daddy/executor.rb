require 'watir-webdriver'
require 'date'

# require 'no_daddy/logging'
# require 'no_daddy/batch'

module NoDaddy
	class Executor

		def initialize(batch)
			@batch = batch
		end

		def login(username, password)
			@browser = Watir::Browser.new :firefox

			@username = username

			#login to godaddy
			@browser.goto "http://godaddy.com"
			@browser.link(text: "Log In").click
			@browser.text_field(title: "Enter Username").set(username)
			@browser.text_field(title: "Enter Password").set(password)
			@browser.link(id: "pc-loginSubmitBtn").click
		end

		# ----------------------------------------------------------------------------
		# data gathering methods
		# ----------------------------------------------------------------------------

		# Records all authenticated account domains.
		# 
		def log_domains
			goto_domains_list

			table = @browser.table(id: 'ctl00_cphMain_DomainList_gvDomains')

			table.rows.each do |r|
				
				domain_model = NoDaddy::Domain.new

				# domain info
				domain_model[:url] 						= r.cells[1].text
				domain_model[:status] 				= r.cells[3].text

				# Date/Time
				#   listed as -- "9/30/2012"
				#   stored as -- "#<Date: 2001-09-30 ((2452183j,0s,0n),+0s,2299161j)>"
				domain_model[:expire_date]		= Date.strptime(r.cells[2].text, '%m/%d/%Y')
				
				# log info
				domain_model[:username]			= @username
				domain_model[:batch]				= @batch
				domain_model[:created_at]		= Time.now
				domain_model[:updated_at]		= Time.now

				domain_model.save!
			end
		end

		# ----------------------------------------------------------------------------
		# navigation methods
		# ----------------------------------------------------------------------------

		def goto_domains_list
			# go to domains center
			@browser.goto("https://mya.godaddy.com/products/ControlPanelLaunch/ControlPanelLaunch.aspx?accordionId=1&generic=true")
		end

		def goto_domain_manager(domain)
			goto_domains
			
			@browser.a(text: domain).click
			@browser.input(value: domain).wait_until_present
		end


		# ----------------------------------------------------------------------------
		# domain manager page methods
		# ----------------------------------------------------------------------------

		def unlock
		end

		# Changes the nameservers.
		# Requires the brower to be on the domain manger page.
		# 
		def change_nameservers(logger, domain, new_ns)
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

			# logger.write hash.to_yaml
			return hash
		end

	end
end