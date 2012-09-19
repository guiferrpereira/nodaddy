class NoDaddy::Domain 
	include Mongoid::Document

	field :url, 								type: String
	field :expire_date, 				type: Date
	field :status, 							type: String
	field :locked, 							type: Boolean
	field :in_transfer_process, type: Boolean
	field :name_servers_old, 		type: Array
	field :name_servers_new, 		type: Array
end

