require 'csv'
require 'yaml'

class NoDaddy::Logging
	
	def self.check_dir_yml
		if Dir.glob("*.yml").size > 0
			new_home = "previous_yml"

			FileUtils.mkdir new_home unless Dir.exist?(new_home)
			
			FileUtils.mv(Dir.glob("*.yml"), new_home, :verbose => true)
		end
	end

	def self.csv
		log_filename = Dir.glob("log.csv").empty? ? "log.csv" : Time.now.strftime("%Y%m%dT%H%M%S%z") + ".csv"
	
		csv_writer = CSV.open(log_filename, "w")
	end

	def self.yaml(file_name)
		file = Dir.glob(file_name).empty? ? file_name : Time.now.strftime("%Y%m%dT%H%M%S%z") + ".yml"
		File.open(file, "w")
	end

	def timestamp_copy(file)
		name = file.split(".")[0]
		type = file.split(".")[1]

		new_file = Time.now.strftime("%Y%m%dT%H%M%S%z") + "." + name + "." + type
		FileUtils.cp file, new_file
	end

	def timestamp_remove(file)
		timestamp_copy(file)
		FileUtils.rm file
	end

end
