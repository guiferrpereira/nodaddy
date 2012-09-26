require 'yaml'
require 'csv'
require 'set'

module NoDaddy
	class Loader

		def load_domain_settings(file_name=nil)
			errors = []

			file_name = "/domains_settings.csv" unless file_name

			# get all /config/settings/domains_*.rb files
			current_dir = File.dirname(File.expand_path(__FILE__))
			path_to_settings = File.join("..", "..", "..", "config", "settings")			
			path =  current_dir + "/" + path_to_settings + file_name

			files = Dir.glob(path)

			# expected CSV headers
			expected_header_set = Set.new(["url", "ns1", "ns2", "ns3", "ns4"])

			files.each do |f|
				csv = CSV.read(f, { headers: :first_row,  skip_blanks: true })
				
				csv_header_set = Set.new(csv.headers)
				check_headers(expected_header_set, csv_header_set)

				# for each row, load into DomainSetting
				csv.by_row.each do |r|
					url = ""
					nameservers = []
					
					begin
						url = r[0]
						nameservers << r[1]
						nameservers << r[2]
						nameservers << r[3]
						nameservers << r[4]
					rescue Exception => e
						msg = "ERROR: " + url.to_s + " - " + e.to_s
						errors << msg
					end

					unless errors.nil?
						ds = DomainSetting.new
						ds.url = url
						ds.nameservers = nameservers
						ds.save!
 					end
				end
			end
			result = errors.empty? ? true : errors 

			return true
		end

		protected
			# Ensures correct mapping between file values and object values.
			# Returns true for matching headers.
			# 
			def check_headers(expected_set, file_set)
				# lowercase
				comparison = expected_set ^ file_set.collect(&:downcase)
				
				# upcase
				unless comparison.empty?
					comparison = expand_set ^ file_set.collect(&:upcase)
				end 

				# abort message
				unless comparison.empty?
					msg = "ERROR: Loaded CSV headers did not match expected headers," 
					msg = msg + "\n-> Loaded headers   = " + file_set.to_a.to_s
					msg = msg + "\n-> Expected headers = " + expected_set.to_a.to_s
					
					abort(msg)
				end

				true
			end

			# Deletes all DomainSettings for specified url.
			# 
			def delete_domain_setting(url)
				DomainSetting.delete_all(url: url)
			end
	end
end