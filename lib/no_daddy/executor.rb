require 'watir-webdriver'

class NoDaddy::Executor

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