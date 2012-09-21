require 'csv'
require 'yaml'

module NoDaddy
	class Session

		def initialize(file=nil, env=nil)
			path 				= file || File.dirname(__FILE__) + "/../../config/mongoid.yml"
			environment = env  || :development
			
			set_db(path, environment)

			puts "batch number = " + @batch.number.to_s
		end

		def set_db(p, e)
			Mongoid.load!(p, e)
			generate_batch
		end

		def batch
			@batch
		end

		private

			def generate_batch
				b = Batch.new
				b.number = NoDaddy::Batch.max(:number) + 1
				b.save! ? @batch = b : false
			end


		# --------------------------------------------------------------------------
		# old stuff
		# --------------------------------------------------------------------------

		# def check_dir_yml
		# 	if Dir.glob("*.yml").size > 0
		# 		new_home = "previous_yml"

		# 		FileUtils.mkdir new_home unless Dir.exist?(new_home)
				
		# 		FileUtils.mv(Dir.glob("*.yml"), new_home, :verbose => true)
		# 	end
		# end

		# def self.csv
		# 	log_filename = Dir.glob("log.csv").empty? ? "log.csv" : Time.now.strftime("%Y%m%dT%H%M%S%z") + ".csv"
		
		# 	csv_writer = CSV.open(log_filename, "w")
		# end

		# def self.yaml(file_name)
		# 	file = Dir.glob(file_name).empty? ? file_name : Time.now.strftime("%Y%m%dT%H%M%S%z") + ".yml"
		# 	File.open(file, "w")
		# end

		# def timestamp_copy(file)
		# 	name = file.split(".")[0]
		# 	type = file.split(".")[1]

		# 	new_file = Time.now.strftime("%Y%m%dT%H%M%S%z") + "." + name + "." + type
		# 	FileUtils.cp file, new_file
		# end

		# def timestamp_remove(file)
		# 	timestamp_copy(file)
		# 	FileUtils.rm file
		# end

	end
end
