module NoDaddy
	class Session

		def initialize(file=nil, env=nil)
			path 				= file || File.dirname(__FILE__) + "/../../../config/mongoid.yml"
			environment = env  || :development
			set_db(path, environment)
		end

		def set_db(path, environment)
			Mongoid.load!(path, environment)
			generate_batch
		end

		def batch
			@batch
		end


		private
			def generate_batch
				b = Batch.new
        b.number = 1
        b.number = NoDaddy::Batch.max(:number) + 1 if NoDaddy::Batch.max(:number)
				b.save! ? @batch = b : false
			end

	end
end
