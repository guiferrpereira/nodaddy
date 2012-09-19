require 'mongoid'

module NoDaddy

	class Database
		def self.set
			Mongoid.load!("config/mongoid.yml", :development)
		end
	end
end

require 'no_daddy/version'
require 'no_daddy/domain'
require 'no_daddy/logging'
require 'no_daddy/executor'
