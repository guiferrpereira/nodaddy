require 'watir-webdriver'
require 'date'

module NoDaddy
	class Executor

		def initialize(batch)
			@batch = batch
		end

		def login(username, password)
			@browser = Watir::Browser.new :firefox

			@username = username
      @password = password
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

      anotherPage = false
      begin
        @browser.table(id: 'ctl00_cphMain_DomainList_gvDomains').wait_until_present
        table = @browser.table(id: 'ctl00_cphMain_DomainList_gvDomains')

        domains_count = table.rows.count

        table.rows.each_with_index do |r, i|
          domain_model = NoDaddy::Domain.new

          # domain info
          domain_model[:url]					= r.cells[1].text
          domain_model[:status] 			= r.cells[3].text

          # Date/Time
          #   listed as -- "9/30/2012"
          #   stored as -- "#<Date: 2001-09-30 ((2452183j,0s,0n),+0s,2299161j)>"
          domain_model[:expire_date]	= Date.strptime(r.cells[2].text, '%m/%d/%Y')
          
          # log info
          domain_model[:username]			= @username
          domain_model[:created_at]		= Time.now
          domain_model[:updated_at]		= Time.now

          # related domain to batch process
          domain_model.batch = @batch 

          domain_model.save!

          print "#{i} of #{domains_count}" + "\r"
        end

        # find the next button and click it if it's not disabled
        nextButton = @browser.button(:id, 'ctl00_cphMain_DomainList_btnBottomNext')
        if nextButton.nil?
          STDERR.puts "is nil"
        else
	        disabled = nextButton.attribute_value("disabled")
          STDERR.puts "disabled: #{disabled.inspect}"
	        if disabled.nil?
            STDERR.puts "Go to next button"
	          anotherPage = true
	          nextButton.click
	        else
            STDERR.puts "Button is disabled"
	          anotherPage = false
	        end
        end
	    end while anotherPage == true
      STDERR.puts "anotherPage #{anotherPage}"
		end

		# ----------------------------------------------------------------------------
		# navigation methods
		# ----------------------------------------------------------------------------

		def goto_domains_list
			# go to domains center
			@browser.goto("https://mya.godaddy.com/products/ControlPanelLaunch/ControlPanelLaunch.aspx?accordionId=1&generic=true")
		end

		def goto_domain_manager(domain)
			goto_domains_list
		
      @browser.text_field(:id, 'ctl00_cphMain_DomainList_txtJumpTo').set domain
      @browser.input(:id, 'ctl00_cphMain_DomainList_btnGo').click
      @browser.a(text: domain).wait_until_present
			@browser.a(text: domain).click
			@browser.input(value: domain).wait_until_present
		end


		# ----------------------------------------------------------------------------
		# domain manager page methods
		# ----------------------------------------------------------------------------

		# Send authorization code to GoDaddy account email for transfer. 
		# 
		def send_authorization_code(domain)
			begin
				# get authorization ifram
				@browser.a(id: 'ctl00_cphMain_lnkAuthCodeEmail').click
				@browser.frame(id: 'ifrm').wait_until_present(10)
				
				# click OK to send email
				@browser.frame(id: 'ifrm').link(text: 'OK').click
				
				# click OK to get past notification back to domain manage dashboard
				@browser.frame(id: 'ifrm').link(text: 'OK').click
				
				# save state
				domain.auth_code_sent = true
			rescue Exception => e
				puts e.to_s
			end

			domain.save!
		end

		# Unlock domain for transfer.
		# Requires browser to be on the domain manager page.
		# 
		def unlock(domain)
			# get unlock iframe
			begin
				@browser.a(id: 'ctl00_cphMain_lnkDomainLock').click
				@browser.frame(id: 'ifrm').wait_until_present(10)
			rescue Exception => e
				 puts e.to_s
			end

			# unlock and submit unlocked domains
			# keep unlocked domains as unlocked
			begin
				checkbox = @browser.frame(id: 'ifrm').checkbox

				# unlocked 'locked' domain
				if checkbox && checkbox.set?
					checkbox.clear if checkbox.set?
					@browser.frame(id: 'ifrm').link(text: 'OK').click
					domain.unlocked = true
				
				# do nothing, domain already unlocked
				elsif checkbox && !checkbox.set?
					@browser.frame(id: 'ifrm').link(text: 'Cancel').click
					domain.unlocked = true
				
				# do nothing, domain is not locked or unlocked
				else
					puts "domain != locked || unlocked"
					domain.unlocked = nil
				end

			rescue Exception => e
				puts e.to_s
			end

			domain.save!
		end

		# Changes the nameservers.
		# Requires browser to be on the domain manager page.
		# 
		def change_nameservers(domain, nameservers_new)

			errors = []
			ns_old = []
			ns_new = []

      if (rand()*30).to_i == 15
        @browser.close
        self.login(@username, @password)
        sleep 1
        self.goto_domain_manager(domain.url)
      end

			# get name server iframe
			unless errors.nil?
				begin
					@browser.a(id: 'ctl00_cphMain_lnkNameserverUpdate').click
					@browser.frame(id: 'ifrm').wait_until_present(10)
				rescue Exception => e
					errors.push(e.to_s)
				end
			end

			# log old nameservers 
			unless errors.nil?
				begin
					0.upto(3) do |index|
						old_ns = @browser.frame(id: 'ifrm').input(id: "ctl00_cphAction1_ctl00_txtNameserver#{index + 1}").value
						ns_old.push(old_ns)
					end
				rescue Exception => e
					errors.push(e.to_s)
				end
			end	

			# set new nameservers
			unless errors.nil?
				begin
					nameservers_new.each_with_index do |ns, index|
						@browser.frame(id: 'ifrm').text_field(id: "ctl00_cphAction1_ctl00_txtNameserver#{index + 1}").set(ns)
						ns_new.push(ns)
					end
				rescue Exception => e
					errors.push(e.to_s)
				end
			end

			# submit new nameserver values
			unless errors.nil?
				begin
					@browser.frame(id: 'ifrm').a(text: 'OK').click
					@browser.frame(id: 'ifrm').div(id: 'ctl00_cphAction1_ctl01_pnlReadOnly').wait_until_present
					@browser.frame(id: 'ifrm').a(text: 'OK').click
				rescue Exception => e
					errors.push(e.to_s)
				end

				domain.updated_at = Time.now
			end

			# transfer local variables to domain object
			domain.go_daddy_errors = errors
			domain.name_servers_new = ns_new
			domain.name_servers_old = ns_old
			
			return domain.save!
		end

	end
end
