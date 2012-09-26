module NoDaddy
	class DomainSetting
		include Mongoid::Document

		field :url,           type: String
		field :nameservers,   type: Array
	end
end
